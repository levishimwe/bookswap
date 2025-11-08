const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configure with environment variables (set via `firebase functions:config:set`)
// Example:
// firebase functions:config:set smtp.email="you@example.com" smtp.pass="app-password" smtp.host="smtp.gmail.com" smtp.port=465
const smtp = functions.config().smtp || {};
const transporter = nodemailer.createTransport({
  host: smtp.host,
  port: Number(smtp.port || 465),
  secure: true,
  auth: { user: smtp.email, pass: smtp.pass }
});

async function sendEmail(to, subject, html) {
  if (!smtp.email || !smtp.pass || !smtp.host) {
    console.warn('SMTP not configured; skipping email send');
    return;
  }
  await transporter.sendMail({ from: smtp.email, to, subject, html });
}

exports.onNewMessageEmail = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const { receiverId, senderName, text } = data;
    // Lookup receiver email
    const userDoc = await admin.firestore().collection('users').doc(receiverId).get();
    const to = userDoc.exists ? userDoc.data().email : null;
    if (!to) return;
    await sendEmail(
      to,
      `New message from ${senderName}`,
      `<p>You have a new message:</p><p><b>${senderName}:</b> ${text}</p>`
    );
  });

exports.onNewAccessRequestEmail = functions.firestore
  .document('access_requests/{requestId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    const { ownerId, requesterName, bookTitle, type } = data;
    const userDoc = await admin.firestore().collection('users').doc(ownerId).get();
    const to = userDoc.exists ? userDoc.data().email : null;
    if (!to) return;
    await sendEmail(
      to,
      `Access request for ${bookTitle}`,
      `<p>${requesterName} requested access to <b>${type}</b> "${bookTitle}".</p>`
    );
  });

exports.onAccessDecisionEmail = functions.firestore
  .document('access_requests/{requestId}')
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.status === after.status) return;
    const { requesterId, bookTitle, status } = after;
    const userDoc = await admin.firestore().collection('users').doc(requesterId).get();
    const to = userDoc.exists ? userDoc.data().email : null;
    if (!to) return;
    await sendEmail(
      to,
      `Your request for ${bookTitle} was ${status}`,
      `<p>Your access request for "${bookTitle}" is now: <b>${status}</b>.</p>`
    );
  });
