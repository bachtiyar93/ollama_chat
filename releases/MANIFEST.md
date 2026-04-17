# Release Manifest - v1.0.0

Generated: April 17, 2026

## Release Contents

### Web Build
- **File:** ollama-chat-web-v1.0.0.tar.gz
- **Size:** 12 MB (compressed)
- **Format:** Tar.gz compressed archive
- **Contents:** Complete Flutter web build with all assets
- **Platform:** Cross-platform (deploy to any static hosting)
- **Usage:** Extract and serve via HTTP server or deploy to Firebase/Netlify

### Android APK
- **File:** ollama-chat-v1.0.0.apk
- **Size:** 54 MB
- **Format:** Android Package
- **Platform:** Android 21+ (API level 21 and above)
- **Usage:** Install on Android device via adb or manual installation

### Documentation
- **File:** RELEASE_NOTES_v1.0.0.md
- **Size:** ~6 KB
- **Format:** Markdown
- **Contents:** Complete release notes, features, known issues

## How to Use

### Web Deployment

**Option 1: Local Testing**
```bash
tar -xzf ollama-chat-web-v1.0.0.tar.gz
cd web
python3 -m http.server
# Open: http://localhost:8000
```

**Option 2: Firebase Hosting**
```bash
firebase deploy --only hosting
# Upload web/ folder to your Firebase project
```

**Option 3: Netlify**
```bash
netlify deploy --prod --dir=web
```

**Option 4: Any Static Hosting**
- Extract the archive
- Upload `web/` folder contents to your hosting provider
- Configure server to serve `index.html` for all routes

### Android Installation

**Method 1: ADB (Android Studio/CLI)**
```bash
adb install ollama-chat-v1.0.0.apk
```

**Method 2: Manual**
- Transfer APK to Android device
- Open file manager
- Tap the APK file
- Confirm installation

**Method 3: Google Play Store (Future)**
- Coming in future release

## Checksums

### Web Build
- Filename: ollama-chat-web-v1.0.0.tar.gz
- Size: 12582912 bytes (12 MB)
- Type: Compressed archive

### APK
- Filename: ollama-chat-v1.0.0.apk
- Size: 56623616 bytes (54 MB)
- Target: Android 21+
- Architecture: arm64-v8a, armeabi-v7a

## System Requirements

### Web
- Modern web browser (Chrome, Firefox, Safari, Edge)
- JavaScript enabled
- Network connection to Ollama server
- Ollama running on accessible host

### Android
- Android 5.0 (API 21) or higher
- ~60 MB free storage
- Network connection to Ollama server
- Ollama running on accessible host

## Dependencies

### Ollama
- Version: Latest (tested with 0.x)
- Model: qwen2.5-coder:3b
- Status: Must be running and accessible
- Setup: See DEVELOPMENT_GUIDE.md

### Network
- Ollama must be accessible from the device
- Default: localhost:11434
- Configurable: Edit lib/config/ollama_config.dart

## Configuration

### Host Configuration
Edit in `lib/config/ollama_config.dart`:
```dart
static const String defaultLocalhost = 'localhost';
static const String fallbackHost = '192.168.0.208';
```

### Other Settings
- Request timeout: 300 seconds (5 minutes)
- Max message length: 10000 characters
- Model: qwen2.5-coder:3b
- Context window: 4096 tokens

## Troubleshooting

### Web Build Won't Load
- Ensure Ollama is running
- Check browser console for errors
- Verify network connection
- Check firewall settings

### APK Won't Install
- Ensure Android 5.0+
- Check "Unknown sources" enabled in settings
- Try: `adb install -r ollama-chat-v1.0.0.apk` (force reinstall)
- Clear app data if upgrading

### "Connection Refused"
- Start Ollama: `ollama serve`
- Check if running on correct host/port
- Update host in config if needed

### "Model Not Found"
- Pull model: `ollama pull qwen2.5-coder:3b`
- Wait for download to complete
- Restart Ollama

## Version Information

- **App Version:** 1.0.0
- **Build Number:** 1
- **Flutter Version:** 3.11.4+
- **Dart Version:** 3.11.4+
- **Release Date:** April 17, 2026

## Support Files

All support files are in the root of the repository:

- **CODE_REVIEW.md** - Code analysis findings
- **FIXES_APPLIED.md** - Detailed fixes
- **DEVELOPMENT_GUIDE.md** - Development reference
- **QUICK_SUMMARY.md** - Quick overview
- **README.md** - Project description
- **START_HERE.md** - Getting started

## Update Information

To check for updates:
```bash
cd your-project
git pull origin master
```

Current release: v1.0.0
Latest commit: [Check GitHub]

## Verification

### Build Verification
- ✅ Web build size: 12 MB
- ✅ APK build size: 54 MB
- ✅ All assets included
- ✅ No missing dependencies

### Testing Status
- ✅ Chat functionality: Working
- ✅ Error handling: Comprehensive
- ✅ Code highlighting: Working
- ✅ Theme support: Working
- ✅ Performance: Optimized

## Future Releases

### v1.1 (Planned)
- Chat history persistence
- iOS support
- Export/import functionality

### v2.0 (Planned)
- Multiple model support
- User authentication
- Advanced API features
- Database persistence

## Archive Contents

### Web Archive Structure
```
web/
├── index.html              - Main HTML entry point
├── flutter.js              - Flutter runtime
├── flutter_bootstrap.js    - Bootstrap script
├── main.dart.js            - Compiled Dart code (~4MB)
├── flutter_service_worker.js - Service worker
├── assets/                 - App assets
│   └── logo.svg
├── canvaskit/              - Canvas rendering engine
└── icons/                  - App icons
```

### APK Contents
- Compiled Flutter app
- All dependencies
- Assets and resources
- Native libraries (arm64-v8a, armeabi-v7a)

## Notes

- Web version works best on Chrome/Edge
- APK supports both 32-bit and 64-bit Android devices
- Ollama must be running on a network-accessible host
- Configure host in code for your environment

---

**Release Date:** April 17, 2026
**Version:** 1.0.0
**Status:** ✅ Production Ready

