# Jomiyo Mall — Mobile App Installation & Setup Guide

This guide details everything required to clone, configure, build, and deploy the Jomiyo Mall mobile application on Android and iOS devices.

---

## 1. Prerequisites & Environment Requirements

| Requirement | Minimum Version | Recommended Version |
| :--- | :--- | :--- |
| **Flutter SDK** | `>= 3.22.0` | `3.38.10` or latest stable |
| **Dart SDK** | `>= 3.4.0` | `3.10.9` or latest stable |
| **Android SDK** | API Level 23 (Android 6.0) | API Level 35/36 (Android 15) |
| **JDK (Java)** | JDK 17 | Eclipse Temurin / JetBrains Runtime 17.0.14 |
| **Gradle** | 8.0+ | Managed via Flutter Gradle Plugin |
| **Xcode** (for iOS) | 15.0+ | Latest with iOS 17/18 SDKs |
| **CocoaPods** (for iOS) | 1.14+ | Latest |

---

## 2. Quick Setup

### Step 1: Clone or Navigate to Project
```bash
cd /Users/ashishranjan/.gemini/antigravity/scratch/jomiyo_mall
```

### Step 2: Configure Environment Variables
Set your Java 17 path (especially on macOS with Android Studio or Homebrew):
```bash
export JAVA_HOME="/Users/ashishranjan/Library/Java/JavaVirtualMachines/jbr-17.0.14/Contents/Home"
```

### Step 3: Fetch Dependencies
```bash
flutter pub get
```

### Step 4: Run Static Analysis & Tests
```bash
flutter analyze
flutter test
```
*Expected: 0 errors, all tests passing.*

---

## 3. Running on Emulator or Physical Device

### Android:
1. Ensure your device is plugged in with USB debugging enabled, or launch an Android Virtual Device (AVD).
2. Check connected devices:
   ```bash
   flutter devices
   ```
3. Run in debug mode:
   ```bash
   flutter run -d <device_id>
   ```

### iOS:
1. Open the iOS project in Xcode or ensure an iPhone simulator is open.
2. Install CocoaPods dependencies:
   ```bash
   cd ios && pod install && cd ..
   ```
3. Run on simulator:
   ```bash
   flutter run -d "iPhone 15"
   ```

---

## 4. Production Build Commands

### Android Release APK:
```bash
flutter build apk --release
```
*Output path:* `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (AAB for Google Play Store):
```bash
flutter build appbundle --release
```
*Output path:* `build/app/outputs/bundle/release/app-release.aab`

### iOS Release Archive (for App Store / TestFlight):
```bash
flutter build ipa --release
```
*Output path:* `build/ios/archive/Runner.xcarchive` and `build/ios/ipa/*.ipa`

---

## 5. Security & Proguard Configuration
The application is preconfigured with:
- Proguard rules preserving Dio, Riverpod, and JSON Serializable models.
- HTTP cleartext traffic disabled in release (`android:usesCleartextTraffic="false"`).
- Network security config ensuring strict HTTPS communication.
- Sensitive credentials stored using Flutter Secure Storage (`KeyStore` on Android, `Keychain` on iOS).
