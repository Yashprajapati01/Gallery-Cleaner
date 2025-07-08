# 📱 Gallery Cleaner

> A Tinder-style gallery cleaner app built with Flutter. Swipe through your photos and videos to quickly organize and clean up your device's gallery.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

## 🚀 What is GalleryCleaner?

Gallery Cleaner transforms the tedious task of cleaning your photo gallery into an engaging, swipe-based experience. Just like Tinder, but for your photos and videos! View one media item at a time and make quick decisions to keep your gallery organized.

### ✨ Key Features

- **👉 Swipe Right to Keep** - Save photos and videos you want to preserve
- **👈 Swipe Left to Mark for Deletion** - Queue unwanted media for removal
- **🔄 Undo Last Swipe** - Changed your mind? No problem!
- **🗑️ Deletion Management** - Review, restore, or permanently delete marked items
- **🎞️ Full Media Support** - View images and play videos in fullscreen
- **📦 Optimized Performance** - Lazy loading and responsive design for smooth experience

## 📸 Screenshots

<!-- Add your screenshots here -->
Swiper Screen       |  Delete Screen
:-------------------------:|:-------------------------:
<img src="gitAssets\Swiper screen.jpeg"> |  <img src="gitAssets\delete screen.jpeg">

Image preview       |  video preview
:-------------------------:|:-------------------------:
<img src="gitAssets\image preview.jpeg"> |  <img src="gitAssets\video preview.jpeg">

## 🏗️ Architecture

Built with **Clean Architecture** principles and **BLoC** pattern for maintainable, testable, and scalable code.

```
lib/
├── domain/
│   ├── models/                 # MediaAsset, MediaDecision
│   └── repositories/           # MediaRepository interface
├── infrastructure/
│   └── repositories/           # MediaRepositoryImpl (photo_manager)
├── presentation/
│   ├── screens/                # GallerySwiperScreen, DeleteListScreen
│   ├── bloc/                   # bloc
│   └── widgets/               # MediaCard, SwipeControls
├── di/                        # Dependency Injection setup
└── main.dart
```

## 🧠 State Management

Powered by **flutter_bloc** for predictable state management:

- **SwipeLeft** - Mark media for deletion
- **SwipeRight** - Keep media in gallery
- **UndoSwipe** - Revert last decision
- **ConfirmDelete** - Permanently remove media
- **RestoreMedia** - Move media back from deletion queue

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `photo_manager` | Access device gallery media |
| `appinio_swiper` | Tinder-style swipe interface |
| `flutter_bloc` | State management |
| `get_it` & `injectable` | Dependency injection |
| `photo_view` | photo viewer |
| `permission_handler` | permission handling |
| `video_player` | Video playback support |
| `chewier` | Video playback controls |

## ⚙️ Setup & Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Android/iOS device or emulator

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/your-username/gallery-cleaner.git
cd gallery-cleaner
```

### 2️⃣ Install Dependencies
```bash
flutter pub get
```

### 3️⃣ Generate Dependency Injection Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4️⃣ Configure Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to help you organize your gallery.</string>
```

### 5️⃣ Run the App
```bash
flutter run
```


## 🛣️ Roadmap

### ✅ Completed
- [x] Swipe-to-delete/keep gallery items
- [x] Undo swipe functionality
- [x] Delete list management screen
- [x] Clean Architecture implementation
- [x] Enhanced video playback controls

### 🔄 In Progress
- [ ] Shuffle mode for random media browsing
- [ ] Sort/filter by date, location, file size

### 📋 Planned Features
- [ ] Multiple theme support & dark mode
- [ ] Batch operations
- [ ] Smart suggestions based on duplicates/blur detection

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

For integration tests:
```bash
flutter test integration_test/
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines
- Follow the existing code style
- Write tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Yash Prajapati**

## 🙏 Acknowledgments

- Thanks to the Flutter community for amazing packages
- Inspired by the need for better gallery management tools
- Special thanks to contributors and beta testers

---

<div align="center">
  <p>Made with ❤️ and Flutter by 2Noob2Code</p>
  <p>Star ⭐ this repo if you found it helpful!</p>
</div>
