# Ollama Chat Application - Pembaruan Fitur

## Fitur Baru yang Ditambahkan

### 1. **Auto-Initialization Ollama** ✅
Aplikasi sekarang secara otomatis mengecek dan menjalankan Ollama saat startup tanpa perlu manual:

**Lokasi**: `lib/services/ollama_service.dart`

**Cara Kerja**:
- Saat aplikasi dijalankan, `OllamaService` akan:
  1. Mengecek apakah Ollama sudah berjalan di localhost:11434
  2. Jika belum, akan menjalankan `ollama serve`
  3. Kemudian secara otomatis menjalankan model `qwen2.5-coder:3b`
  4. Menunggu 3 detik untuk model siap sebelum UI ditampilkan

**Keuntungan**:
- Tidak perlu terminal terpisah untuk menjalankan Ollama
- Pengalaman pengguna lebih smooth
- Automatic model loading di background

### 2. **Auto-Focus Input Field** ✅
Setelah AI selesai menjawab, cursor otomatis fokus ke input field chat:

**Implementasi**:
- `ChatProvider` menerima callback `setOnMessageComplete()`
- `ChatScreen` menggunakan `FocusNode` untuk auto-focus
- Setelah pesan AI ditambahkan, callback dipanggil untuk focus input

**Manfaat**:
- User bisa langsung mengetik pertanyaan berikutnya
- Tidak perlu positioning mouse ke field input lagi
- Meningkatkan produktivitas chat experience

## Struktur File

```
lib/
├── services/
│   └── ollama_service.dart        [BARU] Mengelola Ollama initialization
├── providers/
│   ├── chat_provider.dart         [UPDATE] Tambah callback onMessageComplete
│   └── theme_provider.dart
├── views/
│   ├── chat_screen.dart           [UPDATE] Tambah FocusNode management
│   ├── message_bubble.dart
│   └── code_wrapper.dart
├── models/
├── controllers/
└── main.dart                       [UPDATE] Inisialisasi OllamaService
```

## Cara Menjalankan

### Untuk Desktop (Windows/macOS/Linux):
```bash
# Pastikan Ollama sudah terinstall
# Cukup jalankan aplikasi
flutter run -d macos    # untuk macOS
flutter run -d windows  # untuk Windows
flutter run -d linux    # untuk Linux
```

### Untuk Web:
```bash
# OllamaService hanya untuk desktop
# Di browser perlu curl available atau bisa dikonfigurasi ulang
flutter run -d chrome
```

## Catatan Penting

⚠️ **OllamaService hanya berfungsi untuk platform desktop** (macOS, Windows, Linux)
- Menggunakan `Process.run()` dan `dart:io` yang tidak tersedia di web
- Untuk web, pastikan Ollama sudah berjalan secara manual di localhost:11434

✅ **Model akan di-load otomatis** jika:
- Ollama terinstall di system PATH
- Port 11434 tidak diblok oleh firewall

🔧 **Troubleshooting**:
1. Jika Ollama tidak terdeteksi, pastikan sudah diinstall: https://ollama.ai
2. Jika port 11434 error, check: `lsof -i :11434`
3. Check logs Flutter untuk debug initialization

## Update Dependencies

Pastikan `flutter pub get` sudah dijalankan setelah update ini.

## Testing Fitur

1. **Auto-Init Test**:
   - Close Ollama
   - Jalankan app
   - Lihat di console: "Initializing Ollama service..."
   - Ollama seharusnya start otomatis

2. **Auto-Focus Test**:
   - Kirim pesan ke AI
   - Tunggu response selesai
   - Input field harus langsung focused
   - Bisa langsung ketik tanpa klik
