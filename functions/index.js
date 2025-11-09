import { onRequest } from 'firebase-functions/v2/https';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as logger from 'firebase-functions/logger';
import admin from 'firebase-admin';
import nodemailer from 'nodemailer';
import { v4 as uuidv4 } from 'uuid';

admin.initializeApp();
const db = admin.firestore();

// Read SMTP and public app URL from environment (set using Firebase Secrets or env vars)
const SMTP_EMAIL = process.env.SMTP_EMAIL;
const SMTP_PASS = process.env.SMTP_PASS;
const SMTP_HOST = process.env.SMTP_HOST || 'smtp.gmail.com';
const SMTP_PORT = Number(process.env.SMTP_PORT || 465);
const PUBLIC_BASE_URL = process.env.PUBLIC_BASE_URL; // e.g., https://<region>-<project>.cloudfunctions.net

const transporter = (SMTP_EMAIL && SMTP_PASS)
  ? nodemailer.createTransport({
      host: SMTP_HOST,
      port: SMTP_PORT,
      secure: SMTP_PORT === 465,
      auth: { user: SMTP_EMAIL, pass: SMTP_PASS },
    })
  : null;

async function sendEmail(to, subject, html) {
  if (!transporter) {
    logger.warn('SMTP not configured; skipping email send');
    return;
  }
  await transporter.sendMail({ from: SMTP_EMAIL, to, subject, html });
}

function tokenExpiry(hours = 24) {
  const now = admin.firestore.Timestamp.now();
  const ms = hours * 60 * 60 * 1000;
  return admin.firestore.Timestamp.fromMillis(now.toMillis() + ms);
}

async function createActionToken({
  targetCollection,
  targetId,
  action,
  meta = {},
}) {
  const tokenId = uuidv4();
  const doc = {
    tokenId,
    targetCollection,
    targetId,
    action,
    meta,
    used: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: tokenExpiry(24),
  };
  await db.collection('action_tokens').doc(tokenId).set(doc);
  return tokenId;
}

function actionLink(tokenId) {
  if (PUBLIC_BASE_URL) {
    return `${PUBLIC_BASE_URL}/handleAction?token=${tokenId}`;
  }
  // Default Firebase v2 URL template; user should set PUBLIC_BASE_URL after deploy for correctness
  return `https://us-central1-${process.env.GCLOUD_PROJECT}.cloudfunctions.net/handleAction?token=${tokenId}`;
}

// ========== TRIGGERS ==========

export const onSwapCreatedEmail = onDocumentCreated('swaps/{swapId}', async (event) => {
  const data = event.data?.data();
  if (!data) return;
  try {
    const receiverId = data.receiverId;
    const receiver = await db.collection('users').doc(receiverId).get();
    const to = receiver.exists ? receiver.data().email : null;
    if (!to) return;

    // Create tokens
    const acceptToken = await createActionToken({
      targetCollection: 'swaps',
      targetId: event.params.swapId,
      action: 'accept',
      meta: { bookId: data.bookId },
    });
    const rejectToken = await createActionToken({
      targetCollection: 'swaps',
      targetId: event.params.swapId,
      action: 'reject',
      meta: { bookId: data.bookId },
    });

    const acceptUrl = actionLink(acceptToken);
    const rejectUrl = actionLink(rejectToken);
    await sendEmail(
      to,
      `Swap offer for "${data.bookTitle}"`,
      `<p>You received a swap offer from <b>${data.senderName}</b> for book "${data.bookTitle}".</p>
       <p>Choose an action:</p>
       <p><a href="${acceptUrl}">Accept offer</a> | <a href="${rejectUrl}">Reject offer</a></p>`
    );
  } catch (e) {
    logger.error('onSwapCreatedEmail error', e);
  }
});

export const onAccessRequestCreatedEmail = onDocumentCreated('access_requests/{requestId}', async (event) => {
  const data = event.data?.data();
  if (!data) return;
  try {
    const ownerId = data.ownerId;
    const owner = await db.collection('users').doc(ownerId).get();
    const to = owner.exists ? owner.data().email : null;
    if (!to) return;

    const grantToken = await createActionToken({
      targetCollection: 'access_requests',
      targetId: event.params.requestId,
      action: 'grant',
      meta: { bookId: data.bookId, requesterId: data.requesterId },
    });
    const declineToken = await createActionToken({
      targetCollection: 'access_requests',
      targetId: event.params.requestId,
      action: 'decline',
      meta: { bookId: data.bookId, requesterId: data.requesterId },
    });

    const grantUrl = actionLink(grantToken);
    const declineUrl = actionLink(declineToken);
    await sendEmail(
      to,
      `Access request for "${data.bookTitle}"`,
      `<p><b>${data.requesterName}</b> requested access to ${data.type} "${data.bookTitle}".</p>
       <p><a href="${grantUrl}">Grant access</a> | <a href="${declineUrl}">Decline</a></p>`
    );
  } catch (e) {
    logger.error('onAccessRequestCreatedEmail error', e);
  }
});

// ========== HTTPS ACTION HANDLER ==========

export const handleAction = onRequest({ cors: true }, async (req, res) => {
  try {
    const tokenId = String(req.query.token || '');
    if (!tokenId) return res.status(400).send('Missing token');

    const tokenSnap = await db.collection('action_tokens').doc(tokenId).get();
    if (!tokenSnap.exists) return res.status(400).send('Invalid token');
    const token = tokenSnap.data();

    // Check expiry and used
    if (token.used) return res.status(410).send('This action link was already used.');
    if (token.expiresAt && token.expiresAt.toMillis() < Date.now()) {
      return res.status(410).send('This action link has expired.');
    }

    const { targetCollection, targetId, action, meta } = token;

    if (targetCollection === 'swaps') {
      await handleSwapAction({ swapId: targetId, action, bookId: meta?.bookId });
    } else if (targetCollection === 'access_requests') {
      await handleAccessAction({ requestId: targetId, action, bookId: meta?.bookId, requesterId: meta?.requesterId });
    } else {
      return res.status(400).send('Unknown action target');
    }

    // Mark all tokens for this target as used
    const batch = db.batch();
    const related = await db.collection('action_tokens')
      .where('targetCollection', '==', targetCollection)
      .where('targetId', '==', targetId)
      .get();
    related.forEach(doc => batch.update(doc.ref, { used: true, usedAt: admin.firestore.FieldValue.serverTimestamp() }));
    await batch.commit();

    res.set('Content-Type', 'text/html');
    return res.send(renderHtml('Success', 'Your action was applied successfully. You can close this window.'));
  } catch (e) {
    logger.error('handleAction error', e);
    res.status(500).send('Internal error while applying action.');
  }
});

async function handleSwapAction({ swapId, action, bookId }) {
  const swapRef = db.collection('swaps').doc(swapId);
  const updates = { status: action === 'accept' ? 'Accepted' : 'Rejected', respondedAt: admin.firestore.FieldValue.serverTimestamp() };
  const batch = db.batch();
  batch.update(swapRef, updates);
  if (action === 'reject' && bookId) {
    batch.update(db.collection('books').doc(bookId), { isAvailable: true, swapId: null });
  }
  await batch.commit();
}

async function handleAccessAction({ requestId, action, bookId, requesterId }) {
  const reqRef = db.collection('access_requests').doc(requestId);
  const batch = db.batch();
  batch.update(reqRef, { status: action === 'grant' ? 'Accepted' : 'Declined', respondedAt: admin.firestore.FieldValue.serverTimestamp() });
  if (action === 'grant' && bookId && requesterId) {
    batch.update(db.collection('books').doc(bookId), {
      allowedUserIds: admin.firestore.FieldValue.arrayUnion(requesterId),
    });
  }
  await batch.commit();
}

function renderHtml(title, message) {
  return `<!doctype html>
  <html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${title}</title>
  <style>body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,Arial,sans-serif;padding:32px;color:#0f172a;background:#f8fafc} .card{max-width:680px;margin:auto;background:white;border-radius:12px;box-shadow:0 10px 20px rgba(2,8,23,.06);padding:24px} h1{font-size:22px;margin:0 0 12px} p{margin:8px 0}</style>
  </head><body><div class="card"><h1>${title}</h1><p>${message}</p></div></body></html>`;
}
