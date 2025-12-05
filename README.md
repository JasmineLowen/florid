# Florid - F-Droid Client

A modern F-Droid client for Android built with Flutter.

## Features

- **Latest Apps**: Browse recently added and updated apps from F-Droid
- **Categories**: Explore apps organized by categories
- **Updates**: Check for updates to your installed F-Droid apps
- **Search**: Find apps with powerful search functionality
- **App Details**: View detailed information about each app
- **Downloads**: Download APK files with progress tracking
- **Material Design 3**: Modern and beautiful user interface

## Screenshots

*Screenshots will be available after the app is built and tested*

## Functionality

### ✅ Implemented Features:
- Browse latest apps from F-Droid repository
- Browse apps by categories with beautiful category cards
- Search functionality with suggestions
- App details screen with comprehensive information
- Download APK files with progress tracking
- Check for updates to installed apps
- Material Design 3 UI with light/dark theme support
- State management with Provider
- Cached network images for performance
- Pull-to-refresh functionality

### 🚧 Coming Soon:
- APK installation functionality
- Update all apps feature
- Settings screen
- Offline caching
- Repository management
- App screenshots gallery

## Technical Details

### Architecture:
- **State Management**: Provider pattern
- **API Integration**: HTTP client with F-Droid API
- **UI Framework**: Flutter with Material Design 3
- **Data Models**: JSON serialization with code generation
- **Image Caching**: Cached network image loading
- **Permissions**: Android permissions for storage and installation

### F-Droid API:
The app uses F-Droid's public API to fetch:
- Repository index (index-v2.json)
- App metadata and descriptions
- Categories and search results
- Version information and download URLs

### File Structure:
```
lib/
├── models/          # Data models (FDroidApp, FDroidVersion, etc.)
├── providers/       # State management (AppProvider, DownloadProvider)
├── screens/         # UI screens (Latest, Categories, Updates, etc.)
├── services/        # API services (FDroidApiService)
├── widgets/         # Reusable UI components
└── main.dart        # App entry point
```

## Getting Started

### Prerequisites:
- Flutter 3.9.2 or higher
- Android SDK for Android development
- Android device or emulator

### Installation:

1. **Clone the repository** (if applicable):
   ```bash
   git clone <repository-url>
   cd florid
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code** (for JSON serialization):
   ```bash
   dart run build_runner build
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Building APK:
```bash
flutter build apk --release
```

## Permissions

The app requires the following Android permissions:

- **INTERNET**: For API calls to F-Droid repository
- **READ_EXTERNAL_STORAGE**: For accessing downloaded files
- **WRITE_EXTERNAL_STORAGE**: For downloading APK files
- **REQUEST_INSTALL_PACKAGES**: For APK installation (future feature)
- **QUERY_ALL_PACKAGES**: For checking installed apps

## Dependencies

Key packages used:
- `provider`: State management
- `http`: API calls
- `dio`: File downloads
- `cached_network_image`: Image caching
- `device_apps`: Installed apps information
- `permission_handler`: Android permissions
- `url_launcher`: External URL handling
- `share_plus`: App sharing functionality
- `json_annotation`: JSON serialization

## Contributing

This is a Flutter project that demonstrates building a complete F-Droid client. Feel free to:
- Report bugs and issues
- Suggest new features
- Submit pull requests
- Improve documentation

## License

This project is open source. Please check the LICENSE file for details.

## Acknowledgments

- F-Droid project for providing the open-source app repository
- Flutter team for the excellent framework
- Material Design team for the design system

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
