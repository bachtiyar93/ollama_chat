# Jobseeker AI - Career Assistant Chatbot

## 🎯 Overview
**Jobseeker AI** adalah aplikasi chat interaktif yang membantu pencari kerja mendapatkan konsultasi karir menggunakan model AI Qwen2.5-coder:3b melalui Ollama.

## ✨ Fitur Utama

### 1. **Logo & Branding** 🎨
- Logo custom SVG dengan desain profesional (briefcase + checkmark)
- Title aplikasi: **"Jobseeker Assistance"**
- Subtitle di AppBar: **"Jobseeker AI - Career Assistant"**
- Warna brand: Indigo (#6366f1) yang modern dan profesional

### 2. **Chat dengan AI** 💬
- Percakapan real-time dengan Qwen2.5-coder model
- Auto-load model saat startup (desktop only)
- Penyimpanan riwayat chat dalam session
- Loading indicator saat AI sedang memikirkan

### 3. **Code Block Support** 📝
- Auto-detection code blocks (```, import, class, function, {})
- Syntax highlighting untuk berbagai bahasa
- Copy button untuk code snippets
- Wrapper khusus untuk visual yang lebih baik

### 4. **Copy Functionality** 📋
- Icon salin pada setiap pesan (question & answer)
- Copy button khusus di dalam code wrapper
- Toast notification setelah copy berhasil

### 5. **Theme Management** 🎭
- System theme (mengikuti setting device)
- Light theme
- Dark theme
- Tema tersimpan di SharedPreferences

### 6. **Auto-Focus Input** ⌨️
- Input field otomatis fokus setelah AI selesai menjawab
- Tidak perlu click field untuk mengetik pertanyaan berikutnya
- Pengalaman chat yang lebih smooth

### 7. **Auto-Initialize Ollama** 🚀
- Otomatis cek & jalankan Ollama serve saat startup (desktop)
- Auto-load model qwen2.5-coder:3b
- User tidak perlu manual setup

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| macOS | ✅ Full Support | Auto-Ollama initialization |
| Windows | ✅ Full Support | Auto-Ollama initialization |
| Linux | ✅ Full Support | Auto-Ollama initialization |
| Web | ⚠️ Limited | Manual Ollama setup required |

## 🏗️ Struktur Project

```
lib/
├── main.dart                      # Entry point & app setup
├── models/
│   ├── message.dart              # Message model
│   └── theme_mode.dart           # Theme enum
├── providers/
│   ├── chat_provider.dart        # Chat state management
│   └── theme_provider.dart       # Theme state management
├── controllers/
│   └── chat_controller.dart      # Chat business logic
├── services/
│   └── ollama_service.dart       # Ollama initialization
└── views/
    ├── chat_screen.dart          # Main chat UI
    ├── message_bubble.dart       # Message widget
    └── code_wrapper.dart         # Code block widget

assets/
└── logo.svg                      # Jobseeker AI logo

pubspec.yaml                      # Dependencies & config
```

## 🎯 Key Specifications

- **Project Name**: jobseeker_ai
- **App Title**: Jobseeker Assistance
- **AI Name**: Jobseeker AI
- **Subtitle**: Career Assistant
- **Model**: Qwen2.5-coder:3b (via Ollama)
- **API**: localhost:11434
- **Architecture**: MVC + Multi-Provider

## 📦 Dependencies

```yaml
provider: ^6.1.2              # State management
http: ^1.2.1                  # HTTP requests
clipboard: ^0.1.3             # Clipboard operations
flutter_highlight: ^0.7.0     # Code syntax highlighting
flutter_svg: ^2.2.3           # SVG rendering
shared_preferences: ^2.2.3    # Local storage
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Ollama installed & available in PATH
- macOS / Windows / Linux

### Installation

```bash
# Clone atau buka project
cd /Users/raizel/Developer/ollama_chat

# Install dependencies
flutter pub get

# Run aplikasi (desktop)
flutter run -d macos      # untuk macOS
flutter run -d windows    # untuk Windows
flutter run -d linux      # untuk Linux

# Untuk web (setup manual Ollama dulu)
ollama serve              # Di terminal lain
ollama run qwen2.5-coder:3b
flutter run -d chrome
```

## 💡 Cara Menggunakan

1. **Jalankan aplikasi** - Ollama auto-start (desktop only)
2. **Ketik pertanyaan karir** di input field
3. **Tekan Enter atau tombol Send**
4. **Tunggu AI memberikan jawaban**
5. **Copy jawaban** dengan icon copy di pesan
6. **Pertanyaan berikutnya** - input field auto-fokus

## 🎨 UI/UX Highlights

- **Clean Material Design** dengan Indigo accent color
- **Responsive layout** untuk berbagai ukuran layar
- **Dark/Light mode** support penuh
- **Smooth animations** dengan circular progress indicator
- **Professional logo** di AppBar dengan subtitle

## 🔧 Teknologi

- **Framework**: Flutter 3.11.4+
- **State Management**: Provider (Multi-Provider)
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences
- **Code Highlighting**: flutter_highlight
- **SVG Rendering**: flutter_svg
- **Backend**: Ollama (local)

## 📝 Notes

- Semua fitur sudah tested tanpa error ✅
- Auto-Ollama hanya untuk desktop (menggunakan dart:io)
- Web version memerlukan manual Ollama setup
- Chat history tersimpan selama session berjalan
- Theme preference tersimpan secara persistent

## 🤝 Support

Untuk troubleshooting atau pertanyaan, check:
- Ollama running: `curl http://localhost:11434/api/tags`
- Model loaded: `ollama list`
- Port available: `lsof -i :11434`

---

**Dibuat dengan ❤️ menggunakan Flutter & Ollama**

