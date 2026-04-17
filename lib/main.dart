import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'services/ollama_service.dart';
import 'services/gemini_service.dart';
import 'services/openai_service.dart';
import 'providers/settings_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'views/welcome_screen.dart';
import 'views/chat_screen.dart';
import 'views/widgets/settings_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider.value(value: hiveService),
        Provider(create: (_) => OllamaService()),
        Provider(create: (_) => GeminiService()),
        Provider(create: (_) => OpenAIService()),
        ChangeNotifierProxyProvider<HiveService, SettingsProvider>(
          create: (context) => SettingsProvider(context.read<HiveService>()),
          update: (context, hive, previous) => previous!..loadSettings(),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, ThemeProvider>(
          create: (context) => ThemeProvider(),
          update: (context, settings, theme) => theme!..updateFromSettings(settings.themeMode),
        ),
        ChangeNotifierProxyProvider4<HiveService, OllamaService, GeminiService, OpenAIService, ChatProvider>(
          create: (context) => ChatProvider(
            context.read<HiveService>(),
            context.read<OllamaService>(),
            context.read<GeminiService>(),
            context.read<OpenAIService>(),
          ),
          update: (context, hive, ollama, gemini, openai, previous) => previous!..loadHistory(),
        ),
      ],
      child: const JobseekerApp(),
    ),
  );
}

class JobseekerApp extends StatelessWidget {
  const JobseekerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Jobseeker AI',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.flutterThemeMode,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  bool _showChat = false;

  @override
  Widget build(BuildContext context) {
    if (_showChat) {
      return const ChatScreen();
    }

    return Scaffold(
      body: WelcomeScreen(
        onStartChat: () => setState(() => _showChat = true),
        onOpenSettings: () {
          showDialog(
            context: context,
            builder: (context) => const SettingsDialog(),
          );
        },
      ),
    );
  }
}
