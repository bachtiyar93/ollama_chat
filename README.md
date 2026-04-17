# Ollama Chat - Jobseeker AI

A Flutter application that serves as an AI-powered career assistant chatbot, integrating with Ollama to provide interactive consultations for job seekers using the Qwen2.5-coder:3b model.

## ✨ Features

- **AI Career Assistant**: Interactive chat with Jobseeker AI powered by Qwen2.5-coder model
- **Auto-Server Detection**: Automatically detects local Ollama server or falls back to remote server (192.168.0.208)
- **Multi-Platform Support**: Works on macOS, Windows, Linux, Web, and Android
- **Smart Fallback**: Android users automatically connect to remote server without local Ollama installation
- **Markdown Rendering**: Rich text support with code syntax highlighting
- **Theme Support**: System, light, and dark theme options
- **Input Validation**: Prevents abuse with message length limits and spam detection
- **Error Handling**: Comprehensive error messages with actionable solutions
- **Resource Management**: Proper cleanup to prevent memory leaks
- **Request Timeout**: 5-minute timeout to prevent hanging requests

## How to Run the Project

### Prerequisites
- Flutter SDK installed ([Installation Guide](https://docs.flutter.dev/get-started/install))
- Ollama installed and available in PATH ([Download Ollama](https://ollama.ai/))
- Supported platforms: macOS, Windows, Linux (full support with auto-Ollama), Web (limited, manual setup required), Android (with remote server fallback)

### Installation Steps
1. Clone or open the project:
   ```
   cd /Users/raizel/Developer/ollama_chat
   ```

2. Install Flutter dependencies:
   ```
   flutter pub get
   ```

3. For desktop (macOS/Windows/Linux):
   ```
   flutter run -d macos    # for macOS
   flutter run -d windows  # for Windows
   flutter run -d linux    # for Linux
   ```
   Ollama will auto-start and load the model.

4. For web:
   - Start Ollama manually in another terminal:
     ```
     ollama serve
     ollama run qwen2.5-coder:3b
     ```
   - Then run:
     ```
     flutter run -d chrome
     ```

5. For Android:
   - Ensure your device is connected or emulator is running.
   - Run:
     ```
     flutter run -d android
     ```
   - The app will automatically detect the Ollama server.

## Usage
1. Launch the app - Ollama initializes automatically on desktop.
2. Type career-related questions in the input field.
3. Press Enter or the Send button.
4. Wait for AI responses.
5. Copy answers using the copy icon on messages.
6. The input field auto-focuses for the next question.

## Ownership
This code is owned by the author (Raizel). It is shared for educational and testing purposes. Feel free to try, run, and modify the code for your own use, but please respect the ownership and give credit if you build upon it.

For more detailed information, see [JOBSEEKER_AI_README.md](JOBSEEKER_AI_README.md).

## Getting Started with Flutter

If this is your first Flutter project, here are some resources:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.
