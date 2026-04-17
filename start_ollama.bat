@echo off
REM 🚀 OLLAMA SERVER STARTER FOR WINDOWS
REM Created: April 17, 2026
REM For: Ollama Chat - Jobseeker AI Project
REM Owner: Raizel

echo 🤖 Starting Ollama Server for Jobseeker AI...
echo ==============================================

REM Function to check if Ollama is running
:check_ollama
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% equ 0 (
    goto :ollama_running
) else (
    goto :ollama_not_running
)

:ollama_running
echo ✅ Ollama server is already running
goto :load_model

:ollama_not_running
echo 🚀 Starting Ollama server...
start /B ollama serve
timeout /t 3 /nobreak >nul

REM Check again
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Ollama server started successfully
    goto :load_model
) else (
    echo ❌ Failed to start Ollama server
    echo Please check if Ollama is installed and try again
    pause
    exit /b 1
)

:load_model
echo 🤖 Loading Jobseeker AI model (qwen2.5-coder:3b)...

REM Check if model exists
ollama list | findstr "qwen2.5-coder:3b" >nul 2>&1
if %errorlevel% equ 0 (
    echo 📦 Model found locally, running...
    ollama run qwen2.5-coder:3b
) else (
    echo ⬇️ Model not found, downloading...
    ollama pull qwen2.5-coder:3b
    if %errorlevel% equ 0 (
        echo ✅ Model downloaded successfully
        ollama run qwen2.5-coder:3b
    ) else (
        echo ❌ Failed to download model
        pause
        exit /b 1
    )
)

echo.
echo 🎉 Jobseeker AI is ready!
echo.
echo 💡 Next steps:
echo    1. Open new terminal/command prompt
echo    2. Run: flutter run -d windows
echo    3. Start chatting with Jobseeker AI!
echo.
echo 🛑 To stop Ollama server later:
echo    - Open Task Manager (Ctrl+Shift+Esc)
echo    - Find "ollama.exe" in Processes
echo    - Right-click → End Task
echo.
pause
