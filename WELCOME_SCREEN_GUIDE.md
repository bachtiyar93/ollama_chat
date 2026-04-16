# Welcome Screen - Jobseeker AI

## 🎉 Fitur Welcome Screen

Tampilan menarik ketika aplikasi dibuka untuk pertama kali (belum ada chat).

## ✨ Design Elements

### 1. **Logo dengan Glow Effect** 🌟
- Logo SVG Jobseeker AI ditampilkan besar di tengah
- Efek shadow/glow dengan warna primary
- Ukuran: 120x120 pixels
- Responsive pada berbagai ukuran layar

### 2. **Welcome Message** 💬
```
Welcome to Jobseeker AI
Your Career Companion
```
- Title besar & bold
- Subtitle dengan warna lebih soft
- Text alignment center

### 3. **Decorative Divider** ✨
- Garis horizontal indigo
- Pemisah visual yang elegant
- Ukuran: 60x3 pixels

### 4. **Description** 📝
```
Get expert advice on career development, job interviews, 
resume optimization, and professional growth.
```
- Penjelasan singkat tentang aplikasi
- Multi-line dengan height yang nyaman dibaca

### 5. **Quick Tips Section** 💡
```
💡 Quick Tips

✓ Ask about interview tips and strategies
✓ Get resume improvement suggestions
✓ Learn about career paths and skills
✓ Discuss salary negotiation techniques
```
- Box dengan background semi-transparent
- Icon check di setiap tips
- Border subtle dengan warna primary

### 6. **Start Chatting Button** 🚀
- Gradient background (primary → primary 80%)
- Ukuran penuh width (full-width button)
- Icon chat + text
- Shadow effect untuk depth
- Hover effect dengan InkWell

### 7. **Keyboard Shortcut Hint** ⌨️
```
Press Tab or Ctrl+/ to focus input field
```
- Teks kecil di bawah button
- Warna muted gray
- Italic style

## 🎨 Colors & Styling

| Element | Color | Opacity |
|---------|-------|---------|
| Logo Glow | Primary | 0.3 |
| Title | TextColor | 1.0 |
| Subtitle | Gray[600] | 1.0 |
| Tips Box BG | Primary | 0.08 |
| Tips Box Border | Primary | 0.2 |
| Button | Primary → Primary 0.8 | - |
| Button Shadow | Primary | 0.3 |
| Hint Text | Gray[500] | 1.0 |

## 🌓 Dark Mode Support

- Automatic text color adjustment
- Logo glow matches theme
- Button colors adapt to theme
- All backgrounds respect dark mode

## 📱 Responsive Design

- `SingleChildScrollView` untuk mobile
- Padding 24px horizontal (adaptive)
- Column centered dengan `mainAxisAlignment`
- Full width button
- Responsive text sizes

## 🔄 Transition

Welcome screen **otomatis hilang** ketika:
- User mengirim pesan pertama
- Ada message di chat history
- Kondisi: `chatProvider.messages.isEmpty`

Kemudian tampil chat list normally.

## 🎯 User Flow

```
1. App dibuka
   ↓
2. Tampil Welcome Screen (jika messages kosong)
   ↓
3. User klik "Start Chatting" → Input field fokus
   ↓
4. User ketik pertanyaan & enter
   ↓
5. Welcome Screen hilang, chat list tampil
   ↓
6. Chat normal berjalan
```

## 💅 UI/UX Features

✅ Smooth scrolling
✅ Responsive layout
✅ Dark/Light mode support
✅ Glow effect untuk visual depth
✅ Professional gradient button
✅ Keyboard shortcuts hint
✅ Icon + text combination
✅ Proper spacing & typography

## 📦 Dependencies

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
```

## 🛠️ Implementation

File: `lib/views/welcome_screen.dart`

Diintegrasikan ke `chat_screen.dart`:
```dart
chatProvider.messages.isEmpty
    ? WelcomeScreen(onStartChat: () { _focusNode.requestFocus(); })
    : ListView.builder(...)
```

## 📝 Tips Content Samples

- "Ask about interview tips and strategies"
- "Get resume improvement suggestions"
- "Learn about career paths and skills"
- "Discuss salary negotiation techniques"

Dapat disesuaikan sesuai kebutuhan di file `welcome_screen.dart`.

---

**Welcome Screen menciptakan first impression yang hebat untuk Jobseeker AI!** ✨

