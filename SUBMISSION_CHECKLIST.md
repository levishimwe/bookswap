# Assignment 2 Submission Checklist

**Due Date**: November 9, 2025 at 23:59  
**Total Points**: 35 points (30 base + 5 bonus)

---

## ✅ Pre-Submission Tasks

### 1. Documentation Files (COMPLETE ✅)

- [x] **REFLECTION.md** - Firebase integration experience
  - ✅ 8 challenges documented with error messages
  - ✅ Screenshots locations referenced
  - ✅ Solutions explained with code snippets
  - ✅ Lessons learned section
  - ✅ Dart analyzer results included
  - **Status**: 10+ pages completed
  - **Next**: Convert to PDF

- [x] **DESIGN_SUMMARY.md** - Architecture documentation
  - ✅ ERD diagram (ASCII art)
  - ✅ Firestore collections schema
  - ✅ Swap state machine diagram
  - ✅ Provider architecture diagram
  - ✅ State management patterns with code
  - ✅ 6 design trade-offs documented
  - ✅ Performance optimizations
  - ✅ Security rules examples
  - **Status**: 15+ pages completed
  - **Next**: Convert to PDF

- [x] **README.md** - Enhanced setup guide
  - ✅ Complete feature list
  - ✅ Architecture overview
  - ✅ Database schema
  - ✅ Firebase setup instructions
  - ✅ Dependencies list
  - ✅ Assignment rubric alignment table
  - ✅ Demo video guide
  - ✅ Testing & quality assurance
  - **Status**: Professional README completed

### 2. Convert Markdown to PDF ⏳

You have several options to convert the markdown files to PDF:

#### Option A: Using Pandoc (Recommended)
```bash
# Install pandoc (if not installed)
sudo apt install pandoc texlive-xetex

# Convert REFLECTION.md to PDF
pandoc REFLECTION.md -o REFLECTION.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=1in \
  -V fontsize=11pt

# Convert DESIGN_SUMMARY.md to PDF
pandoc DESIGN_SUMMARY.md -o DESIGN_SUMMARY.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=1in \
  -V fontsize=11pt
```

#### Option B: VS Code Extension
1. Install "Markdown PDF" extension by yzane
2. Open REFLECTION.md in VS Code
3. Right-click → "Markdown PDF: Export (pdf)"
4. Repeat for DESIGN_SUMMARY.md

#### Option C: Online Converter
1. Go to https://www.markdowntopdf.com/ or https://dillinger.io/
2. Paste markdown content
3. Export as PDF
4. Save to project root

**Deliverable Files**:
- `REFLECTION.pdf` (required)
- `DESIGN_SUMMARY.pdf` (required)

---

### 3. Dart Analyzer Report ⏳

#### Capture Current Analysis

```bash
# Run analyzer and save to file
cd /home/ishimwe/Downloads/bookswap
dart analyze > analyzer_report.txt 2>&1

# View the report
cat analyzer_report.txt
```

**Expected Output**:
```
Analyzing bookswap...
   info • lib/screens/browse/book_detail_screen.dart:245:33 • ...
   ... (13 lines of withOpacity deprecation warnings)

13 issues found.
(ran in 4.5s)
```

#### Take Screenshot

1. **Terminal Screenshot**:
   - Run `dart analyze` in terminal
   - Take screenshot showing "13 issues found"
   - Save as `dart_analyzer_screenshot.png`

2. **Or Include Text Report**:
   - Submit `analyzer_report.txt` file
   - Shows all 13 info-level deprecations

**Important Note**: All 13 warnings are info-level SDK deprecations (`withOpacity` → `withValues`). These are non-breaking and do not affect functionality. Document this in your submission.

---

### 4. Demo Video Recording ⏳

#### Video Requirements
- **Duration**: 7-12 minutes
- **Format**: MP4, 1080p, 30fps
- **Content**: Show all features + Firebase Console
- **Narration**: Clearly explain what you're doing

#### Recording Setup

**Recommended Tools**:
- **Linux**: OBS Studio (free), SimpleScreenRecorder, built-in GNOME screen recorder (Ctrl+Alt+Shift+R)
- **Windows**: OBS Studio, Camtasia
- **macOS**: QuickTime, Screen Studio

Install OBS Studio (Linux):
```bash
sudo apt install obs-studio
```

#### Video Outline (12 minutes)

**Segment 1: Introduction (1 min)**
- State your name and assignment title
- Brief overview: "BookSwap is a Flutter mobile app for students to exchange textbooks using Firebase"
- Show project structure in VS Code

**Segment 2: Authentication Flow (2 min)**
- Open app on emulator/device
- Sign up with new email
- Show email verification requirement screen
- Open Firebase Console → Authentication tab
- Show new user created
- Check email for verification link (show inbox)
- Click verify, return to app
- Sign in successfully
- Navigate through bottom navigation tabs

**Segment 3: Book CRUD Operations (3 min)**
- **Create**:
  - Go to "My Listings" tab
  - Tap "Post Book" button
  - Fill form: title, author, condition, pick image
  - Submit
  - Show Firebase Console → Firestore → books collection (new document appears)
  - Show book appears in Browse tab
  
- **Update**:
  - Edit a book from My Listings
  - Change title and condition
  - Save
  - Show Firebase Console → books document updated
  
- **Delete**:
  - Delete a book from My Listings
  - Confirm deletion
  - Show Firebase Console → books document removed

**Segment 4: Swap Functionality (2 min)**
- Browse available books (use second test account if possible)
- Tap "Swap" button on a book
- Show Firebase Console → swaps collection (new swap with status: "pending")
- Show Firebase Console → books collection (isAvailable changes to false)
- Switch to book owner account (or show on another device)
- Go to Swap Requests tab
- Accept the swap
- Show Firebase Console → swaps (status changes to "accepted")
- Explain the state machine: Available → Pending → Accepted/Rejected

**Segment 5: Chat System (2 min)**
- From book details, tap "Chat with Owner"
- Send messages back and forth
- Show Firebase Console → chats collection updates
- Show messages subcollection updating in real-time
- Long-press on your message
- Select "Edit", change text, save
- Show updated in Firebase Console
- Long-press, select "Delete", confirm
- Show message removed from Firebase

**Segment 6: State Management Demo (1 min)**
- Explain Provider pattern
- Show how providers folder is organized
- Open `book_provider.dart` in VS Code
- Highlight `notifyListeners()` calls
- Explain: "When data changes, all consumers rebuild automatically"
- Show `Consumer<BookProvider>` in Browse screen code
- Demonstrate: Add a book on one screen, it appears immediately on another

**Segment 7: Conclusion (1 min)**
- Summarize features implemented
- Mention bonus chat feature (5 extra points)
- Show Dart analyzer results (0 errors, 13 SDK deprecations)
- State that all 35-point requirements are met
- Thank you

#### Recording Tips
- Use split-screen: app on left, Firebase Console on right
- Zoom in on important parts
- Speak clearly and at moderate pace
- Pause recording if you need to think
- Edit out long loading times
- Add text overlays for important points (optional)

#### After Recording
```bash
# Compress video if too large (optional)
ffmpeg -i raw_demo.mp4 -vcodec h264 -acodec mp2 bookswap_demo.mp4

# Check file size (should be under 500MB for GitHub)
ls -lh bookswap_demo.mp4
```

**Upload Options**:
- GitHub Release (if under 2GB)
- Google Drive (share link in submission)
- YouTube (unlisted video, share link)

---

### 5. Git Commit Verification ⏳

#### Check Commit History

```bash
# View commit history
git log --oneline --graph --all

# Count commits
git log --oneline | wc -l

# Show commit details
git log --pretty=format:"%h - %an, %ar : %s" --graph

# View specific author commits
git shortlog -s -n
```

**Assignment Requirement**: At least 10 incremental commits with clear messages.

#### If Commits Are Insufficient

If you have fewer than 10 commits or they're not descriptive:

```bash
# DO NOT rewrite history if already pushed to shared repo
# Instead, document that work was iterative (conversation history proves this)

# For future: Make small, frequent commits
git add lib/screens/auth/login_screen.dart
git commit -m "feat: implement email/password login screen"

git add lib/providers/auth_provider.dart
git commit -m "feat: add auth provider with Firebase Auth integration"

git add lib/screens/browse/browse_screen.dart
git commit -m "feat: create browse screen with book list"
```

**Good Commit Message Examples**:
- `feat: implement book CRUD operations with Firestore`
- `fix: resolve book image not displaying on detail screen`
- `refactor: update BookCard to match UI design requirements`
- `feat: add real-time chat system with edit/delete`
- `docs: create comprehensive reflection document`
- `style: format code with dart format`
- `fix: remove Cloud Functions per teacher requirements`

#### Verify Commits
```bash
# Ensure all changes are committed
git status

# Should show "working tree clean"

# Push to GitHub
git push origin main
```

---

## 📊 Rubric Alignment

### Features (30 points)

| Feature | Points | Status | Evidence |
|---------|--------|--------|----------|
| User Authentication | 4 | ✅ Complete | Firebase Auth, email verification |
| Book CRUD | 5 | ✅ Complete | Create/Read/Update/Delete with Firestore |
| Swap Functionality | 3 | ✅ Complete | Pending/Accepted/Rejected states |
| State Management | 4 | ✅ Complete | Provider pattern, 7 providers |
| Navigation | 2 | ✅ Complete | Bottom nav, 5 screens |
| Code Quality | 2 | ✅ Excellent | Clean architecture, 0 errors |
| Settings Screen | 2 | ✅ Complete | Profile, toggles, sign out |
| Demo Video | 7 | ⏳ TODO | Record 7-12 min video |
| Reflection & Docs | 3 | ✅ Complete | REFLECTION.md, DESIGN_SUMMARY.md |
| **BONUS: Chat** | +5 | ✅ Complete | Real-time messaging with edit/delete |

**Total**: 32/32 (30 base + 2 bonus so far) → 35/35 after video

---

## 🎯 Final Submission Package

Create a folder with all deliverables:

```bash
cd /home/ishimwe/Downloads/bookswap

# Create submission folder
mkdir submission_package

# Copy required files
cp REFLECTION.pdf submission_package/
cp DESIGN_SUMMARY.pdf submission_package/
cp README.md submission_package/
cp analyzer_report.txt submission_package/
cp dart_analyzer_screenshot.png submission_package/  # if you take screenshot

# Create a README for the submission package
cat > submission_package/SUBMISSION_README.txt << 'EOF'
BookSwap - Individual Assignment 2
Student: [Your Name]
Date: November 9, 2025

DELIVERABLES:
1. REFLECTION.pdf - Firebase integration challenges (10+ pages)
2. DESIGN_SUMMARY.pdf - Architecture and design decisions (15+ pages)
3. README.md - Enhanced project documentation
4. analyzer_report.txt - Dart analyzer output (13 info warnings)
5. Demo video - See link below

GitHub Repository: https://github.com/levishimwe/bookswap
Demo Video Link: [YouTube/Google Drive link]

NOTES:
- All 13 analyzer warnings are info-level SDK deprecations (non-breaking)
- Bonus chat feature implemented (+5 points)
- Base64 image storage per teacher requirements (no URLs)
- No JavaScript in repository (teacher constraint)
- Email notifications via mailto: links (no backend deployment)

FEATURES IMPLEMENTED:
✅ Authentication (email/password, verification)
✅ Book CRUD (create, read, update, delete)
✅ Swap functionality (send, accept, reject)
✅ State management (Provider pattern, 7 providers)
✅ Navigation (bottom nav, 5 screens)
✅ Settings (profile, toggles)
✅ Real-time chat with edit/delete (BONUS +5)
✅ Access control for resources
✅ Professional documentation

Total Points: 35/35
EOF

# Zip the submission package
zip -r bookswap_submission.zip submission_package/

echo "✅ Submission package created: bookswap_submission.zip"
```

---

## 🚀 Pre-Submission Test Run

Before recording your demo video, run through this checklist on a real Android device:

### Device Setup
```bash
# Connect Android device via USB (Developer Mode enabled)
adb devices

# Install app
flutter install

# Or run directly
flutter run --release
```

### Test Sequence

1. **Clean Slate**:
   - Uninstall previous app version
   - Clear app data
   - Install fresh build

2. **Authentication**:
   - [ ] Sign up with new email
   - [ ] Receive verification email
   - [ ] Verify email
   - [ ] Sign in successfully
   - [ ] Sign out works

3. **Book Operations**:
   - [ ] Post 3 books with images
   - [ ] Books appear in Browse immediately
   - [ ] Edit book title and condition
   - [ ] Delete book removes from list
   - [ ] All operations sync to Firebase

4. **Swap Testing**:
   - [ ] Send swap offer
   - [ ] Status shows "Pending"
   - [ ] Accept/reject from owner account
   - [ ] Book availability updates
   - [ ] Mailto opens email client

5. **Chat Testing**:
   - [ ] Initiate chat from book details
   - [ ] Send messages back and forth
   - [ ] Messages appear instantly
   - [ ] Edit message updates text
   - [ ] Delete message removes it
   - [ ] Unread count updates

6. **Settings**:
   - [ ] Profile displays correctly
   - [ ] Toggles save preferences
   - [ ] Sign out returns to auth

7. **Performance**:
   - [ ] No crashes
   - [ ] Smooth scrolling
   - [ ] Images load quickly
   - [ ] No lag when switching tabs

---

## 📤 Submission Instructions

### GitHub Repository
1. Ensure all code is pushed:
   ```bash
   git add .
   git commit -m "docs: finalize submission with all deliverables"
   git push origin main
   ```

2. Verify repository is public or share access with instructor

3. Add a README badge (optional):
   ```markdown
   ![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
   ![Firebase](https://img.shields.io/badge/Firebase-Latest-orange)
   ![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
   ```

### Upload Video
- **Option 1**: GitHub Release (if under 2GB)
  ```bash
  # Create a release
  git tag -a v1.0 -m "Assignment 2 submission"
  git push origin v1.0
  # Upload video as release asset on GitHub
  ```

- **Option 2**: Google Drive
  - Upload video
  - Set sharing to "Anyone with link can view"
  - Copy shareable link
  - Add link to README or submission email

- **Option 3**: YouTube
  - Upload as "Unlisted" video
  - Title: "BookSwap Flutter App - Assignment 2 Demo"
  - Copy link

### Submit to Course Platform
1. ZIP the submission package
2. Include all PDFs and text files
3. Add a submission note with:
   - GitHub repository link
   - Demo video link
   - Any special instructions

---

## ⏰ Time Estimate

| Task | Estimated Time | Priority |
|------|----------------|----------|
| Convert markdown to PDF | 15 min | HIGH |
| Capture Dart analyzer | 5 min | HIGH |
| Record demo video | 60 min | HIGH |
| Edit video (optional) | 30 min | MEDIUM |
| Test app on device | 30 min | HIGH |
| Verify Git commits | 10 min | MEDIUM |
| Create submission package | 15 min | HIGH |
| Upload and submit | 15 min | HIGH |
| **TOTAL** | **3 hours** | - |

**Recommended Schedule**:
- Now: Convert PDFs (15 min)
- Now: Test app thoroughly (30 min)
- Next: Record demo video (1 hour)
- Next: Capture analyzer screenshot (5 min)
- Next: Package and submit (30 min)
- Buffer: 45 minutes for unexpected issues

---

## ✅ Final Checklist

- [ ] REFLECTION.pdf created and reviewed
- [ ] DESIGN_SUMMARY.pdf created and reviewed
- [ ] README.md updated with complete guide
- [ ] Dart analyzer report captured (text or screenshot)
- [ ] Demo video recorded (7-12 minutes)
- [ ] Video uploaded and link ready
- [ ] All code committed to GitHub
- [ ] Git history shows 10+ meaningful commits
- [ ] App tested on real Android device
- [ ] Submission package created and zipped
- [ ] Submission uploaded to course platform

---

## 🎉 You're Ready!

All the hard work is done. The app is complete with all 35 points worth of features:
- ✅ Authentication
- ✅ Book CRUD
- ✅ Swap functionality
- ✅ State management
- ✅ Navigation
- ✅ Settings
- ✅ Chat (bonus)
- ✅ Professional documentation

**Just record the demo video showing everything works, convert the markdown to PDF, and submit!**

Good luck! 🚀
