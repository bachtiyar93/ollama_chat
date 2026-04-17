# 🛠️ Development Guide - Ollama Chat

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run app
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux

# Make sure Ollama is running
ollama serve
ollama run qwen2.5-coder:3b
```

---

## Configuration

### Ollama Host Configuration
**File:** `lib/config/ollama_config.dart`

```dart
// Default settings - easily customizable
static const String defaultLocalhost = 'localhost';
static const String fallbackHost = '192.168.0.208';
static const int defaultPort = 11434;
static const String modelName = 'qwen2.5-coder:3b';
static const int requestTimeoutSeconds = 300;  // 5 minutes
static const int maxMessageLength = 10000;      // 10KB
```

**Cara mengubah:** Edit nilai di file ini, tidak perlu ubah di mana-mana.

---

## Architecture

```
lib/
├── config/
│   └── ollama_config.dart       ⚙️ Centralized configuration
├── controllers/
│   └── chat_controller.dart     📡 Business logic + validation
├── providers/
│   ├── chat_provider.dart       💬 Chat state + API calls
│   └── theme_provider.dart      🎨 Theme management
├── models/
│   ├── message.dart             📦 Message model
│   └── theme_mode.dart          📦 Theme enum
├── services/
│   └── ollama_service.dart      🚀 Ollama initialization
└── views/
    ├── chat_screen.dart         🖥️ Main UI
    ├── message_bubble.dart       💬 Message widget
    ├── code_wrapper.dart         🎨 Code block widget
    └── welcome_screen.dart       👋 Welcome screen
```

---

## Key Features Implemented

### ✅ Error Handling
All errors now provide **actionable messages** to users:
- Timeout errors → "Check if Ollama is running"
- Connection refused → "Start Ollama with: ollama serve"
- Model not found → "Pull model: ollama pull qwen2.5-coder:3b"
- 500 errors → "Restart Ollama service"

### ✅ Input Validation
- Max message length: 10000 chars
- Spam detection: reject if 80%+ same character
- Empty message: silently ignored

### ✅ Resource Management
- HTTP client properly closed in finally block
- Scroll listeners removed on dispose
- No memory leaks ✨

### ✅ Request Timeout
- Default 5 minutes per request
- Configurable in `ollama_config.dart`
- User sees meaningful timeout message

### ✅ Context Management
- Smart message selection: first 2 + last 8
- Warning if context > 3000 chars
- Prevents token overflow

---

## Common Tasks

### Change Ollama Host
```dart
// In lib/config/ollama_config.dart
static const String fallbackHost = '192.168.0.210';  // Change this
```

### Increase Request Timeout
```dart
// In lib/config/ollama_config.dart
static const int requestTimeoutSeconds = 600;  // 10 minutes
```

### Change Model
```dart
// In lib/config/ollama_config.dart
static const String modelName = 'llama2:13b';  // Change this
```

### Adjust Message Length Limit
```dart
// In lib/config/ollama_config.dart
static const int maxMessageLength = 20000;  // 20KB
```

---

## Debugging

### Enable Debug Logs
```dart
// In chat_provider.dart, debugPrint() statements show:
- Context size warnings
- Timeout events
- HTTP errors
```

### Check Ollama Status
```bash
# Is Ollama running?
curl http://localhost:11434/api/tags

# List available models
ollama list

# Pull model if needed
ollama pull qwen2.5-coder:3b

# Check port usage
lsof -i :11434
```

### Common Issues

| Problem | Solution |
|---------|----------|
| "Connection refused" | Run `ollama serve` |
| "Model not found" | Run `ollama pull qwen2.5-coder:3b` |
| "Request timeout" | Ollama is busy, wait or restart |
| "App lag/crash" | Check memory usage, restart app |
| "Wrong host" | Edit `ollama_config.dart` |

---

## Performance Tips

1. **Keep conversation short:** Avoid 100+ messages (performance degrades)
2. **Monitor context:** Watch for "> 3000 chars" warning in logs
3. **Restart Ollama:** If responses get slow
4. **Limit model:** Use `qwen2.5-coder:3b` (small, fast)

---

## Testing

### Test Input Validation
```dart
// Send very long message (should be rejected)
// Send "aaaaaaa..." repeated (should be rejected)
// Send empty message (should be ignored)
```

### Test Error Handling
```bash
# Stop Ollama while chat running
# Kill process: pkill ollama
# Check error message is helpful
```

### Test Memory
```dart
// Send 50+ messages
// Check app doesn't lag
// Scroll up/down
// Switch themes multiple times
// Close and reopen app
```

---

## Dependencies

```yaml
provider: ^6.1.2              # State management
http: ^1.2.1                  # HTTP requests
clipboard: ^0.1.3             # Copy to clipboard
flutter_highlight: ^0.7.0     # Code syntax highlighting
flutter_svg: ^2.2.3           # SVG rendering
shared_preferences: ^2.2.3    # Local storage
flutter_markdown: ^0.7.7+1    # Markdown rendering
markdown: ^7.1.1              # Markdown parsing
```

---

## Code Quality

### Before Commit
- [ ] No unused imports
- [ ] No hardcoded values (use config)
- [ ] Error handling properly added
- [ ] Memory resources cleaned up
- [ ] Tests pass

### Best Practices
- ✅ Use `OllamaConfig` for all magic numbers
- ✅ Always wrap Provider access in try-catch
- ✅ Clean up controllers/listeners in dispose
- ✅ Provide meaningful error messages
- ✅ Validate user input

---

## Future Improvements

1. **Persistence:** Save chat history to SQLite
2. **Multiple models:** Let user choose model
3. **Streaming UI:** Show real-time token-by-token
4. **Export:** Download chat as JSON/PDF
5. **Analytics:** Track usage patterns
6. **Retry logic:** Auto-retry failed requests
7. **Rate limiting:** Prevent DoS

---

**Happy coding!** 🚀

Last updated: April 17, 2026

