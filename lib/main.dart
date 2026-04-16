import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'views/chat_screen.dart';
import 'services/ollama_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeMode();

  // Initialize Ollama
  await OllamaService().initialize();

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Jobseeker Assistance',
            theme: themeProvider.themeData,
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
