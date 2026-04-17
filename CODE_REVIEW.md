# 🔍 Code Review - Ollama Chat

## 📋 Summary
Ditemukan **9 potensi masalah** yang perlu diperhatikan. Beberapa kritis, beberapa minor.

---

## 🔴 KRITIS - Harus Diperbaiki

### 1. **Hardcoded IP Address** ❌
**File:** `lib/providers/chat_provider.dart` (Line ~91)
```dart
String ollamaHost = '192.168.0.208';  // ❌ HARDCODED!
```
**Masalah:**
- IP tidak fleksibel untuk berbagai device/network
- App akan error saat network berubah
- Tidak bisa digunakan di environment lain

**Solusi:**
- Pindahkan ke environment variable atau config file
- Tambahkan fallback ke `localhost` terlebih dahulu

---

### 2. **Resource Leak - HTTP Client Tidak Dibebankan** ⚠️
**File:** `lib/providers/chat_provider.dart` (Line ~102)
```dart
final client = http.Client();
final request = http.Request(...)
final response = await client.send(request);
// ❌ Client tidak ditutup!
```
**Masalah:**
- Memory leak dari koneksi TCP yang tidak ditutup
- Bisa menyebabkan app lag/crash setelah banyak pesan

**Solusi:**
```dart
// Gunakan try-finally untuk cleanup
try {
  final response = await client.send(request);
  // ... process response
} finally {
  client.close(); // ✅ Selalu tutup
}
```

---

### 3. **Missing Dependencies di pubspec.yaml** 📦
**File:** `lib/views/message_bubble.dart` menggunakan:
```dart
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
```
**Masalah:**
- Paket `flutter_markdown` dan `markdown` tidak disebutkan di pubspec.yaml
- Build akan gagal jika dependencies tidak diinstall

**Solusi:**
Tambahkan ke `pubspec.yaml`:
```yaml
dependencies:
  flutter_markdown: ^0.6.17
  markdown: ^7.1.1
```

---

## 🟡 PENTING - Harus Ditangani

### 4. **Scroll Controller Listener Memory Issue** 🎯
**File:** `lib/views/chat_screen.dart` (Line ~51)
```dart
_scrollController.addListener(_scrollListener);
// ❌ Listener tidak dihapus di dispose
```
**Masalah:**
- Listener tetap aktif walau widget sudah di-dispose
- Bisa menyebabkan memory leak

**Solusi:**
```dart
@override
void dispose() {
  _scrollController.removeListener(_scrollListener); // ✅ Tambahkan ini
  _controller.dispose();
  _scrollController.dispose();
  _focusNode.dispose();
  super.dispose();
}
```

---

### 5. **Error Handling Kurang Detail** 🚨
**File:** `lib/providers/chat_provider.dart` (Line ~140)
```dart
catch (e) {
  _messages[aiMsgIndex] = Message(
    text: 'Error: $e. Pastikan Ollama aktif.',
    isUser: false,
    timestamp: DateTime.now(),
  );
}
```
**Masalah:**
- Error message terlalu generic
- User tidak tahu apa yang salah (network? Ollama down? Model tidak ditemukan?)
- Exception bisa berisi info sensitif

**Solusi:**
```dart
catch (e) {
  String errorMsg;
  if (e is SocketException) {
    errorMsg = 'Network error. Pastikan Ollama running di localhost:11434';
  } else if (e.toString().contains('Status code: 404')) {
    errorMsg = 'Model qwen2.5-coder:3b tidak ditemukan. Jalankan: ollama pull qwen2.5-coder:3b';
  } else if (e.toString().contains('Status code: 500')) {
    errorMsg = 'Server error. Restart Ollama service.';
  } else {
    errorMsg = 'Error: Unable to get response. Please try again.';
  }
  // Set error message
}
```

---

### 6. **No Input Validation** ✋
**File:** `lib/controllers/chat_controller.dart`
```dart
void sendMessage(String message) {
  if (message.trim().isNotEmpty) {
    chatProvider.sendMessage(message.trim());
  }
}
```
**Masalah:**
- Tidak ada validasi panjang message (bisa kirim 100MB string!)
- Tidak ada filter konten berbahaya

**Solusi:**
```dart
void sendMessage(String message) {
  final trimmed = message.trim();
  if (trimmed.isEmpty) return;
  if (trimmed.length > 10000) { // Limit 10KB
    debugPrint('Message too long');
    return;
  }
  chatProvider.sendMessage(trimmed);
}
```

---

### 7. **Missing Null Checks** 🔲
**File:** `lib/views/chat_screen.dart` (Line ~80)
```dart
if (mounted && _focusNode.canRequestFocus) {
  _focusNode.requestFocus();
}
```
**Masalah:**
- `_focusNode` bisa null dalam edge cases
- `context.read<ChatProvider>()` bisa throw error jika provider tidak available

**Solusi:** Tambahkan safety checks di `_setupFocusCallback`

---

## 🟠 MINOR - Bisa Ditingkatkan

### 8. **No Loading Timeout** ⏱️
**File:** `lib/providers/chat_provider.dart`
```dart
final response = await client.send(request);
```
**Masalah:**
- Jika Ollama hang, user tunggu selamanya
- Tidak ada timeout protection

**Solusi:**
```dart
final response = await client.send(request)
    .timeout(
      const Duration(minutes: 5),
      onTimeout: () => throw TimeoutException('Request timeout after 5 minutes'),
    );
```

---

### 9. **Performance: Context Prompt Bisa Terlalu Panjang** 📊
**File:** `lib/providers/chat_provider.dart` (Line ~43-67)
```dart
String _buildContextPrompt(String currentMessage) {
  // ... ambil 2 pertama + 8 terakhir
  // Tapi bisa mencapai 20KB text!
}
```
**Masalah:**
- Setiap request mengirim konteks besar → lambat & boros token
- Context window bisa overflow (4096 tokens)

**Solusi:**
```dart
// Limit total context size
if (prompt.length > 3000) {
  // Truncate atau skip beberapa pesan awal
}
```

---

## ✅ Best Practices yang Sudah Diterapkan

✅ State management menggunakan Provider (baik!)
✅ Theme management tersimpan di SharedPreferences
✅ Auto-focus untuk UX yang smooth
✅ Markdown rendering untuk format response
✅ Syntax highlighting untuk code blocks
✅ Platform detection (Web vs Desktop)

---

## 🛠️ Prioritas Perbaikan

| Priority | Issue | Effort |
|----------|-------|--------|
| 🔴 HIGH | Hardcoded IP | 2 jam |
| 🔴 HIGH | HTTP Client cleanup | 1 jam |
| 🔴 HIGH | Missing dependencies | 30 min |
| 🟡 MEDIUM | Input validation | 1 jam |
| 🟡 MEDIUM | Better error handling | 2 jam |
| 🟠 LOW | Request timeout | 30 min |
| 🟠 LOW | Scroll listener cleanup | 15 min |

---

## 📝 Rekomendasi Next Steps

1. **Buat config file** untuk Ollama host
2. **Tambahkan dependency management** yang proper
3. **Improve error handling** dengan specific messages
4. **Add input validation** dan limits
5. **Test thoroughly** di berbagai network conditions

---

Generated: April 17, 2026

