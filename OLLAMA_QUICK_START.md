# 🎯 OLLAMA SERVER SETUP - COMPLETE GUIDE

**Created:** April 17, 2026
**For:** Ollama Chat - Jobseeker AI Project
**Owner:** Raizel

---

## ⚡ QUICK START (3 Langkah Saja!)

### 1. Jalankan Ollama Server
```bash
# macOS/Linux
./start_ollama.sh

# Windows
start_ollama.bat
```

### 2. Jalankan App
```bash
# Pilih platform Anda
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux
```

### 3. Mulai Chat!
Buka app dan mulai chat dengan Jobseeker AI 🤖

---

## 📁 FILES YANG DIBUAT

### Scripts Otomatis
- **`start_ollama.sh`** - Script untuk macOS/Linux
- **`start_ollama.bat`** - Script untuk Windows

### Dokumentasi Lengkap
- **`OLLAMA_SERVER_COMMANDS.md`** - Semua command reference

---

## 🚀 SINGLE COMMAND CHEATSHEET

### Jalankan Semuanya
```bash
# macOS/Linux
./start_ollama.sh

# Windows
start_ollama.bat
```

### Cek Status
```bash
curl http://localhost:11434/api/tags
```

### Matikan Server
```bash
# macOS/Linux
pkill ollama

# Windows: Task Manager → End "ollama.exe"
```

---

## 📋 MANUAL COMMANDS (Jika Perlu)

### Start Server
```bash
ollama serve &
sleep 3
ollama run qwen2.5-coder:3b
```

### Stop Server
```bash
pkill ollama
```

### Check Status
```bash
# Server running?
curl http://localhost:11434/api/tags

# Models available?
ollama list
```

---

## 🔧 TROUBLESHOOTING

### "Connection refused"
```bash
# Restart server
pkill ollama
./start_ollama.sh
```

### "Model not found"
```bash
# Download model
ollama pull qwen2.5-coder:3b
```

### Port sudah digunakan
```bash
# Check what's using port 11434
lsof -i :11434

# Kill it
lsof -ti:11434 | xargs kill -9
```

---

## ⚙️ CONFIGURATION

### Environment Variables (Opsional)
```bash
# Custom host
export OLLAMA_HOST=0.0.0.0:11434

# Custom model directory
export OLLAMA_MODELS=/path/to/models
```

### Model Info
- **Model:** qwen2.5-coder:3b
- **Size:** ~2GB
- **RAM Required:** 4GB minimum
- **Purpose:** Career assistant chatbot

---

## 📊 MONITORING

### Check Health
```bash
# API status
curl http://localhost:11434/api/tags

# Running processes
ollama ps

# System resources
ps aux | grep ollama
```

---

## 🎯 WORKFLOW HARIAN

### Morning Start
```bash
# Jalankan server dan model
./start_ollama.sh

# Jalankan app
flutter run -d macos
```

### Development
```bash
# Restart jika perlu
./start_ollama.sh restart

# Check logs jika error
ollama logs
```

### End of Day
```bash
# Matikan server
pkill ollama
```

---

## 💡 TIPS & BEST PRACTICES

1. **Always start server first** sebelum run app
2. **Wait 3 seconds** setelah `ollama serve` untuk server initialize
3. **Use background mode** dengan `&` untuk long-running
4. **Check port 11434** jika connection issues
5. **Kill properly** dengan `pkill ollama` bukan force kill
6. **Monitor memory** - model butuh ~4GB RAM
7. **GPU support** - enable jika ada GPU untuk faster responses

---

## 🔄 ALTERNATIVE METHODS

### Docker (Advanced)
```bash
# Run in Docker
docker run -d -p 11434:11434 ollama/ollama

# Load model
docker exec -it <container> ollama run qwen2.5-coder:3b
```

### Systemd Service (Linux Production)
```bash
# Create service
sudo nano /etc/systemd/system/ollama.service

# Content:
[Unit]
Description=Ollama AI Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ollama serve
Restart=always

[Install]
WantedBy=multi-user.target

# Enable & start
sudo systemctl enable ollama
sudo systemctl start ollama
```

---

## 📞 SUPPORT

### Quick Help
- **Server won't start:** Check if Ollama installed
- **Model won't load:** Run `ollama pull qwen2.5-coder:3b`
- **App won't connect:** Ensure server running on port 11434
- **Slow responses:** Check RAM (need 4GB+) and consider GPU

### Full Documentation
See `OLLAMA_SERVER_COMMANDS.md` for complete reference

---

## 🎉 SUCCESS CHECKLIST

- [x] Ollama server scripts created
- [x] Windows & macOS/Linux support
- [x] Single command startup
- [x] Error handling included
- [x] Documentation complete
- [x] Troubleshooting guide included

---

## 🚀 FINAL COMMAND SUMMARY

### Start Everything
```bash
# macOS/Linux
./start_ollama.sh

# Windows
start_ollama.bat
```

### Stop Everything
```bash
pkill ollama
```

### Check Status
```bash
curl http://localhost:11434/api/tags
```

### Run App
```bash
flutter run -d [platform]
```

---

**That's it! 🎉**

Your Ollama server is now ready to power Jobseeker AI.

**Happy chatting! 🤖✨**

---

**Created for:** Ollama Chat - Jobseeker AI
**Date:** April 17, 2026
**Owner:** Raizel
