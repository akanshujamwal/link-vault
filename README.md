# 🔗 Link Vault

> **The modern antidote to "tab fatigue."** A sleek, Firebase-powered Flutter app to store, organize, and share all your important links — with built-in QR code generation and scanning.

---

## 📱 Overview

**Link Vault** is a cross-platform mobile application built with Flutter that acts as your personal link management hub. Whether you're a developer juggling documentation, a student managing research, or a professional curating your social presence — Link Vault keeps everything organized, accessible, and shareable in one place.

---

## ✨ Features

- **🔐 Google Sign-In Authentication** — Secure, one-tap login via Firebase Auth
- **🏠 Profile Dashboard** — A beautiful profile card displaying your name, designation, phone, email, and profile photo
- **🔗 Social Link Management** — Add, edit, and delete links for platforms like LinkedIn, GitHub, Twitter, Instagram, YouTube, LeetCode, Kaggle, and 20+ more
- **📸 QR Code Generation** — Instantly generate a scannable QR code for any link
- **📷 QR Code Scanning** — Scan QR codes and automatically detect URLs to open in-browser
- **📜 Scan History** — Tracks all scanned QR codes both locally (via Hive) and in the cloud (Firestore), synced in real-time
- **🗂️ All Links View** — Paginated grid to browse all saved links beyond the homepage preview
- **📤 Share Profile Card** — Capture and share your profile card as an image with one tap
- **🌑 Dark Theme UI** — Polished, fully dark interface built for readability and style
- **🔄 Real-Time Sync** — Firestore streams keep your data live across devices
- **📶 Offline Support** — Hive local storage keeps scan history available offline

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Authentication | Firebase Auth + Google Sign-In |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Local Storage | Hive Flutter |
| State Management | Flutter BLoC + Equatable |
| QR Generation | qr_flutter |
| QR Scanning | qr_code_scanner_plus |
| Link Sharing | share_plus |
| URL Handling | url_launcher |
| Image Picking | image_picker |

---

## 📂 Project Structure

```
lib/
├── main.dart               # App entry point, Firebase & Hive initialization
├── auth/
│   ├── auth_gate.dart      # Handles routing based on auth state
│   └── auth_service.dart   # Google Sign-In & Firebase Auth logic
├── login/
│   └── login_page.dart     # Login UI
├── home/
│   ├── page/
│   │   └── home_page.dart  # Main dashboard with profile card & links grid
│   └── widgets/
│       ├── add_or_edit_link_dialog.dart
│       ├── add_social_link_dialog.dart
│       ├── animated_exit_dialog.dart
│       ├── circular_avtar_image.dart
│       └── info_card.dart
├── all_links/
│   └── pages/
│       └── all_links_page.dart   # Full grid of all saved links
├── scanner/
│   └── page/
│       ├── scanner_page.dart           # QR code scanner
│       └── generate_qr_code_page.dart  # QR code generator
├── profile/
│   └── profile_page.dart  # Edit profile details & photo
├── services/
│   └── firestore_service.dart  # All Firestore CRUD & stream operations
└── spalsh/
    └── splash_page.dart    # Splash/loading screen
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.9.0`
- Dart SDK `^3.9.0`
- A Firebase project with **Authentication**, **Firestore**, and **Storage** enabled
- Android Studio / Xcode (for platform builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/akanshujamwal/link-vault.git
   cd link-vault
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Go to [Firebase Console](https://console.firebase.google.com/) and create a project
   - Enable **Google Sign-In** under Authentication → Sign-in methods
   - Enable **Cloud Firestore** and **Firebase Storage**
   - Download your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in `android/app/` and `ios/Runner/` respectively
   - Run `flutterfire configure` or manually add `firebase_options.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📖 Usage

### Adding Links
- Tap the **"Add New"** tile in the home grid
- Select a platform (LinkedIn, GitHub, etc.) and paste your URL
- Your link appears in the grid instantly

### Viewing & Sharing QR Codes
- **Tap** any link tile to view its QR code
- From the QR dialog, copy the link or open it in the browser
- **Long press** a link tile for options: Show QR, Edit, or Delete

### Scanning QR Codes
- Navigate to the **Scan** tab in the bottom navigation bar
- Point your camera at a QR code
- If it's a URL, tap **"Open in Browser"** directly from the result dialog
- Scans are automatically saved to your Scan History

### Sharing Your Profile Card
- On the home screen, tap the **share icon** on your profile card
- The card is captured as a PNG and shared via the system share sheet

---

## 📦 Key Dependencies

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.0
google_sign_in: ^6.2.1
cloud_firestore: ^5.6.12
firebase_storage: ^12.4.10
flutter_bloc: ^9.0.0
hive_flutter: ^1.1.0
qr_flutter: ^4.1.0
qr_code_scanner_plus: ^2.0.12
share_plus: ^12.0.0
url_launcher: ^6.3.2
image_picker: ^1.2.0
connectivity_plus: ^7.0.0
intl: ^0.20.2
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a new branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

---

## 📄 License

This project is for personal/educational use. See the repository for license details.

---

## 👤 Author

**Akanshu Jamwal**
- GitHub: [@akanshujamwal](https://github.com/akanshujamwal)
- LinkedIn: [akanshu-jamwal](https://www.linkedin.com/in/akanshu-jamwal)

---

*Built for speed. Organized for growth. Secured for you.*
