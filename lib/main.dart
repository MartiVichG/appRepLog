import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLogged = prefs.getInt('user_id') != null;

  runApp(GymApp(isLogged: isLogged));
}

class GymApp extends StatelessWidget {
  final bool isLogged;
  const GymApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0D1B2A),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676), // Neon Green accent
          secondary: Color(0xFFFF9100), // Orange accent
          surface: Color(0xFF1B263B), // Card color
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B2A),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00E676),
          foregroundColor: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: isLogged ? const HomeScreen() : const LoginScreen(),
    );
  }
}    
