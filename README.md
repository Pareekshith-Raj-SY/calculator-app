# 🧮 Calculator App — Built by Pareekshith

A beautiful, fully-functional Flutter calculator with persistent history and a stunning Light/Blue UI.

---

## ✨ Features
- 🎨 **Beautiful Light/Blue UI** with smooth animations
- 🚀 **Animated Splash Screen** — "Built by Pareekshith"
- ➕ **Full Calculator** — Add, Subtract, Multiply, Divide, Percentage, Toggle Sign
- 📜 **Persistent History** — Saves across app restarts using SharedPreferences
- ♻️ **Reuse history items** — Tap any history entry to reuse the result
- 🗑️ **Clear History** with confirmation dialog
- 📳 **Haptic feedback** on button press

---

## 📁 Project Structure
```
lib/
├── main.dart
├── screens/
│   ├── splash_screen.dart
│   ├── calculator_screen.dart
│   └── history_screen.dart
├── widgets/
│   └── calc_button.dart
└── providers/
    └── calculator_provider.dart
```

---

## 🚀 Getting Started (Local)

### Prerequisites
- Flutter SDK 3.x → https://flutter.dev/docs/get-started/install
- Android Studio or VS Code
- Android device or emulator

### Steps
```bash
# 1. Clone your repo
git clone https://github.com/YOUR_USERNAME/calculator-app.git
cd calculator-app

# 2. Get dependencies
flutter pub get

# 3. Run the app
flutter run

# 4. Build APK manually
flutter build apk --release
```

---

## 🤖 GitHub Actions — Auto Build APK

This project includes a **GitHub Actions workflow** that automatically builds the APK every time you push to `main`.

### How it works:
1. You push code → GitHub detects the push
2. GitHub Actions spins up an Ubuntu runner
3. Flutter is installed, APK is built
4. APK is uploaded as a **downloadable artifact**
5. A **GitHub Release** is also created with the APK attached

### Download your APK:
- Go to **Actions** tab → Click latest run → Download **calculator-release-apk**
- Or go to **Releases** tab to download the latest release APK

---

## 📤 Push to GitHub (Step-by-Step)

> Follow these steps if you're new to GitHub:

### Step 1 — Create a GitHub Account
1. Go to https://github.com
2. Click **Sign Up** and create your account

### Step 2 — Create a New Repository
1. Click **"+"** at the top right → **New repository**
2. Name it: `calculator-app`
3. Set it to **Public**
4. Do NOT initialize with README (we have one)
5. Click **Create repository**

### Step 3 — Install Git
- Windows: https://git-scm.com/download/win
- Mac: Run `xcode-select --install` in Terminal
- Linux: `sudo apt install git`

### Step 4 — Push the Code
Open Terminal / Command Prompt in the project folder:

```bash
git init
git add .
git commit -m "Initial commit - Calculator App by Pareekshith"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/calculator-app.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

### Step 5 — Watch the Build
1. Go to your repo on GitHub
2. Click the **Actions** tab
3. You'll see "Build Flutter APK" running
4. Wait ~5 minutes → Download your APK! 🎉

---

## 📱 Install APK on Android
1. Download the APK from GitHub Actions/Releases
2. Transfer to your Android phone
3. Go to **Settings → Security → Install Unknown Apps** → Enable for your file manager
4. Tap the APK file and install

---

## 👨‍💻 Built by Pareekshith
