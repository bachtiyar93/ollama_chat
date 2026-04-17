# 🚀 OLLAMA SERVER SETUP - Quick Reference

**Created:** April 17, 2026
**For:** Ollama Chat - Jobseeker AI Project
**Owner:** Raizel

---

## ⚡ SINGLE COMMAND QUICK START

### Jalankan Ollama Server + Model dalam 1 Command
```bash
# Jalankan Ollama server dan load model Jobseeker AI
ollama serve & sleep 3 && ollama run qwen2.5-coder:3b
```

### Jalankan App Setelah Ollama Ready
```bash
# Jalankan Flutter app (pilih platform)
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux
```

---

## 🔄 AUTO-DETECTION FEATURE (NEW!)

**App sekarang otomatis mendeteksi server Ollama:**

1. **Coba localhost dulu** (untuk user yang punya Ollama lokal)
2. **Jika tidak ada, fallback ke remote server** (192.168.0.208 - PC Anda)
3. **Android users** akan otomatis menggunakan remote server

### Cara Kerja:
- ✅ **Desktop users**: Coba localhost → jika gagal → remote server
- ✅ **Android users**: Langsung ke remote server (192.168.0.208)
- ✅ **Web users**: Gunakan host saat ini atau remote server

---

## 📋 COMMAND REFERENCE

### 1. START OLLAMA SERVER
```bash
# Jalankan Ollama sebagai server
ollama serve

# Jalankan di background (recommended)
ollama serve &
```

### 2. LOAD MODEL JOBSEEKER AI
```bash
# Load model qwen2.5-coder:3b
ollama run qwen2.5-coder:3b

# Atau pull dulu jika belum ada
ollama pull qwen2.5-coder:3b
```

### 3. CHECK STATUS
```bash
# Cek apakah Ollama running
curl http://localhost:11434/api/tags

# List model yang tersedia
ollama list

# Cek model yang sedang running
ollama ps
```

### 4. STOP OLLAMA SERVER
```bash
# Cara 1: Kill process (Linux/macOS)
pkill ollama

# Cara 2: Kill by port (Linux/macOS)
lsof -ti:11434 | xargs kill -9

# Cara 3: Find and kill (Linux/macOS)
ps aux | grep ollama | grep -v grep | awk '{print $2}' | xargs kill

# Cara 4: Windows Task Manager
# Cari "ollama.exe" di Task Manager → End Task
```

---

## 🔄 AUTOMATED SCRIPTS

### Script untuk macOS/Linux
Buat file `start_ollama.sh`:
```bash
#!/bin/bash

echo "🤖 Starting Ollama Server for Jobseeker AI..."
echo "=============================================="

# Function to check if Ollama is running
check_ollama() {
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to start Ollama server
start_ollama_server() {
    echo "🚀 Starting Ollama server..."
    ollama serve &
    OLLAMA_PID=$!

    # Wait for server to start
    sleep 3

    if check_ollama; then
        echo "✅ Ollama server is running on http://localhost:11434"
        return 0
    else
        echo "❌ Failed to start Ollama server"
        return 1
    fi
}

# Function to load Jobseeker AI model
load_jobseeker_model() {
    echo "🤖 Loading Jobseeker AI model (qwen2.5-coder:3b)..."

    # Check if model exists
    if ollama list | grep -q "qwen2.5-coder:3b"; then
        echo "📦 Model found locally, running..."
        ollama run qwen2.5-coder:3b
    else
        echo "⬇️ Model not found, downloading..."
        ollama pull qwen2.5-coder:3b
        if [ $? -eq 0 ]; then
            echo "✅ Model downloaded successfully"
            ollama run qwen2.5-coder:3b
        else
            echo "❌ Failed to download model"
            return 1
        fi
    fi
}

# Main logic
case "$1" in
    "start")
        echo "🎯 Starting Ollama server and Jobseeker AI model..."

        # Check if already running
        if check_ollama; then
            echo "ℹ️ Ollama server is already running"
            load_jobseeker_model
        else
            if start_ollama_server; then
                load_jobseeker_model
            fi
        fi
        ;;

    "stop")
        stop_ollama
        echo "✅ Ollama server stopped"
        ;;

    "status")
        if check_ollama; then
            echo "✅ Ollama server is running on http://localhost:11434"
            echo "📊 Available models:"
            ollama list
        else
            echo "❌ Ollama server is not running"
        fi
        ;;

    "restart")
        echo "🔄 Restarting Ollama server..."
        stop_ollama
        sleep 2
        if start_ollama_server; then
            load_jobseeker_model
        fi
        ;;

    "model")
        if check_ollama; then
            load_jobseeker_model
        else
            echo "❌ Ollama server is not running. Start server first:"
            echo "   $0 start"
        fi
        ;;

    *)
        echo "📖 Ollama Server Manager for Jobseeker AI"
        echo ""
        echo "Usage: $0 {start|stop|status|restart|model}"
        echo ""
        echo "Commands:"
        echo "  start   - Start Ollama server and load Jobseeker AI model"
        echo "  stop    - Stop Ollama server"
        echo "  status  - Check server status and list models"
        echo "  restart - Restart Ollama server"
        echo "  model   - Load Jobseeker AI model (server must be running)"
        echo ""
        echo "Quick start:"
        echo "  $0 start"
        echo ""
        echo "💡 App auto-detects server: localhost → 192.168.0.208 (remote)"
        ;;
esac

echo ""
echo "💡 For more commands, see: OLLAMA_SERVER_COMMANDS.md"
echo "🚀 Happy chatting with Jobseeker AI!"
```

**Jadikan executable:**
```bash
chmod +x start_ollama.sh
```

**Jalankan:**
```bash
./start_ollama.sh
```

### Script untuk Windows
Buat file `start_ollama.bat`:
```batch
@echo off
echo 🚀 Starting Ollama Server...

REM Start Ollama server in background
start /B ollama serve

REM Wait for server to start
timeout /t 3 /nobreak > nul

REM Check if server is running
curl -s http://localhost:11434/api/tags > nul
if %errorlevel% equ 0 (
    echo ✅ Ollama server is running
) else (
    echo ❌ Ollama server failed to start
    exit /b 1
)

REM Load Jobseeker AI model
echo 🤖 Loading Jobseeker AI model...
ollama run qwen2.5-coder:3b

REM Optional: Stop server
REM taskkill /F /IM ollama.exe
```

**Jalankan:**
```batch
start_ollama.bat
```

---

## 🛠️ TROUBLESHOOTING

### Ollama Tidak Bisa Start
```bash
# Check port 11434 apakah digunakan
lsof -i :11434

# Kill process yang menggunakan port
lsof -ti:11434 | xargs kill -9

# Restart Ollama
ollama serve
```

### Model Tidak Ditemukan
```bash
# Pull model
ollama pull qwen2.5-coder:3b

# List model yang tersedia
ollama list

# Remove model jika corrupt
ollama rm qwen2.5-coder:3b
ollama pull qwen2.5-coder:3b
```

### Connection Refused
```bash
# Check Ollama running
ps aux | grep ollama

# Restart server
pkill ollama
ollama serve &
sleep 3
ollama run qwen2.5-coder:3b
```

### Port Already in Use
```bash
# Find what's using port 11434
lsof -i :11434

# Kill the process
lsof -ti:11434 | xargs kill -9

# Or change port (advanced)
OLLAMA_HOST=0.0.0.0:11435 ollama serve
```

---

## ⚙️ CONFIGURATION

### Environment Variables
```bash
# Set custom host
export OLLAMA_HOST=0.0.0.0:11434

# Set model directory
export OLLAMA_MODELS=/path/to/models

# Set GPU layers (if available)
export OLLAMA_GPU_LAYERS=35
```

### Ollama Config File
Lokasi: `~/.ollama/config` (Linux/macOS) atau `%USERPROFILE%\.ollama\config` (Windows)

```yaml
# Example config
host: 0.0.0.0:11434
models: /opt/ollama/models
gpu-layers: 35
```

---

## 📊 MONITORING

### Check Server Health
```bash
# API health check
curl http://localhost:11434/api/tags

# Model info
curl http://localhost:11434/api/show -d '{"name":"qwen2.5-coder:3b"}'

# System info
curl http://localhost:11434/api/ps
```

### Performance Monitoring
```bash
# Check memory usage
ps aux | grep ollama

# Check GPU usage (if applicable)
nvidia-smi

# Check network connections
netstat -tlnp | grep 11434
```

---

## 🚀 PRODUCTION DEPLOYMENT

### Docker (Recommended for Production)
```bash
# Run Ollama in Docker
docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama

# Load model
docker exec -it ollama ollama run qwen2.5-coder:3b
```

### Systemd Service (Linux)
Buat file `/etc/systemd/system/ollama.service`:
```ini
[Unit]
Description=Ollama AI Server
After=network.target

[Service]
Type=simple
User=ollama
Group=ollama
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

**Commands:**
```bash
# Enable service
sudo systemctl enable ollama

# Start service
sudo systemctl start ollama

# Check status
sudo systemctl status ollama

# Stop service
sudo systemctl stop ollama
```

---

## 📝 QUICK REFERENCE CHEATSHEET

### Daily Usage
```bash
# Start everything
ollama serve & sleep 3 && ollama run qwen2.5-coder:3b

# Check status
curl http://localhost:11434/api/tags

# Stop everything
pkill ollama
```

### Development
```bash
# Start server
ollama serve &

# Load model
ollama run qwen2.5-coder:3b

# Test API
curl http://localhost:11434/api/generate -d '{"model":"qwen2.5-coder:3b","prompt":"Hello"}'

# Stop
pkill ollama
```

### Troubleshooting
```bash
# Check logs
ollama logs

# Reset everything
pkill ollama
rm -rf ~/.ollama
ollama serve &
sleep 3
ollama pull qwen2.5-coder:3b
```

---

## 💡 TIPS & TRICKS

1. **Always start server first:** `ollama serve` before `ollama run`
2. **Wait 3 seconds:** Server needs time to initialize
3. **Background mode:** Use `&` for background operation
4. **Check port:** Use `lsof -i :11434` to verify
5. **Kill properly:** Use `pkill ollama` to stop cleanly
6. **Model size:** qwen2.5-coder:3b is ~2GB, ensure disk space
7. **Memory:** Model needs ~4GB RAM minimum
8. **GPU:** Enable GPU for faster responses

---

## 🔗 USEFUL LINKS

- **Ollama Official:** https://ollama.ai/
- **Model Library:** https://ollama.ai/library
- **API Documentation:** https://github.com/jmorganca/ollama/blob/main/docs/api.md
- **Troubleshooting:** https://github.com/jmorganca/ollama/blob/main/docs/troubleshooting.md

---

**Created for:** Ollama Chat - Jobseeker AI Project
**Date:** April 17, 2026
**Owner:** Raizel

**Single Command Quick Start:**
```bash
ollama serve & sleep 3 && ollama run qwen2.5-coder:3b
```

**Stop Command:**
```bash
pkill ollama
```

**Happy chatting! 🤖✨**
