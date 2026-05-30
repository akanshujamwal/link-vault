# 🚀 Link Vault

> **Your Digital Presence. Organized, Accessible, and Shareable.**

Link Vault is a modern, Firebase-powered Flutter application that helps users store, organize, and share important links from a single platform. With secure authentication, real-time cloud synchronization, QR code integration, and an elegant user experience, Link Vault transforms scattered URLs into a centralized digital hub.

Whether you're a developer managing project resources, a student organizing research materials, or a professional curating your online presence, Link Vault provides a seamless way to access and share your links anytime, anywhere.

---

## ✨ Features

### 🔐 Secure Authentication
- Google Sign-In powered by Firebase Authentication
- Secure and seamless login experience
- User-specific cloud data management

### 👤 Personal Profile Dashboard
- Custom profile card
- Profile photo support
- Name, designation, email, and contact information management

### 🔗 Smart Link Management
- Add, edit, and delete links effortlessly
- Support for 20+ popular platforms
- Organized and user-friendly interface
- Instant access to all saved links

### 📱 QR Code Integration
- Generate QR codes for any saved link
- Scan QR codes and automatically detect URLs
- Open scanned links directly in the browser

### ☁️ Real-Time Cloud Sync
- Firebase Firestore integration
- Automatic synchronization across devices
- Live updates using Firestore streams

### 📂 Scan History
- Track all scanned QR codes
- Cloud backup with Firestore
- Offline access using Hive local storage

### 📤 Easy Sharing
- Share individual links
- Share profile card as an image
- Quick access to your digital identity

### 🌙 Modern UI
- Fully responsive Flutter interface
- Dark theme optimized design
- Smooth animations and clean user experience

---

## 🏗️ Architecture

The application follows clean architecture principles with a scalable and maintainable code structure.

### Tech Stack

| Category | Technology |
|-----------|------------|
| Framework | Flutter |
| Language | Dart |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| State Management | Flutter BLoC |
| Local Storage | Hive |
| QR Generation | qr_flutter |
| QR Scanning | qr_code_scanner_plus |
| Sharing | share_plus |
| URL Launcher | url_launcher |

---

## 📸 Core Modules

- Authentication Module
- Profile Management
- Social Link Management
- QR Code Generator
- QR Code Scanner
- Scan History
- Cloud Synchronization
- Offline Storage
- Profile Card Sharing

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Firebase Project
- Android Studio / VS Code
- Android Emulator, iOS Simulator, or Physical Device

### Installation

```bash
git clone https://github.com/akanshujamwal/link-vault.git

cd link-vault

flutter pub get
```

### Configure Firebase

1. Create a Firebase project.
2. Enable:
   - Firebase Authentication (Google Sign-In)
   - Cloud Firestore
   - Firebase Storage
3. Add:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

### Run the Application

```bash
flutter run
```

---

## 🎯 Use Cases

- Developers managing portfolio links
- Students organizing educational resources
- Professionals sharing social profiles
- Freelancers maintaining digital identity
- Teams sharing frequently used resources

---

## 📈 Future Roadmap

- Link Categories & Folders
- Custom Themes
- Analytics Dashboard
- Link Click Tracking
- Team Collaboration
- Public Profile Pages
- Custom QR Code Styling

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository
2. Create your feature branch

```bash
git checkout -b feature/amazing-feature
```

3. Commit your changes

```bash
git commit -m "Add amazing feature"
```

4. Push to GitHub

```bash
git push origin feature/amazing-feature
```

5. Open a Pull Request

---

## 👨‍💻 Author

### Akanshu Jamwal

**Flutter Developer • Mobile App Engineer • Open Source Enthusiast**

- GitHub: https://github.com/akanshujamwal
- LinkedIn: https://linkedin.com/in/akanshu-jamwal

---

## ⭐ Support

If you found this project useful, consider giving it a **Star ⭐** on GitHub.

Your support helps the project grow and motivates future improvements.

---

<div align="center">

### Built with Flutter ❤️ and powered by Firebase ☁️

**Organize. Share. Connect.**

</div>
