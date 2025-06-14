// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/todo_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showOnboarding = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Modern Todo App',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),
              cardTheme: CardTheme(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            home: _showOnboarding
                ? OnboardingScreen(
                    onGetStarted: () => setState(() => _showOnboarding = false),
                  )
                : const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}