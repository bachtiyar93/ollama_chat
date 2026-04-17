#!/bin/bash

# 🚀 OLLAMA SERVER STARTER
# Created: April 17, 2026
# For: Ollama Chat - Jobseeker AI Project
# Owner: Raizel

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

# Function to stop Ollama
stop_ollama() {
    echo "🛑 Stopping Ollama server..."
    pkill ollama 2>/dev/null
    sleep 2
}

# Function to start Ollama server
start_ollama_server() {
    echo "🚀 Starting Ollama server..."
    ollama serve &
    OLLAMA_PID=$!
    echo "📝 Ollama server PID: $OLLAMA_PID"
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
        echo "⬇️ Model not found, pulling from registry..."
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
        echo "Then run the app:"
        echo "  flutter run -d macos"
        ;;
esac

echo ""
echo "💡 For more commands, see: OLLAMA_SERVER_COMMANDS.md"
echo "🚀 Happy chatting with Jobseeker AI!"
