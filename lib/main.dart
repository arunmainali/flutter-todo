import 'package:flutter/material.dart';
import 'package:todo_list/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFFF9FAFB);     // background
    const accentColor = Color(0xFF3B82F6);   // primary / highlights
    const contrastColor = Color(0xFF111827); // text / icons

    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: accentColor,
          onPrimary: Colors.white,
          secondary: accentColor.withOpacity(0.85),
          onSecondary: Colors.white,
          surface: baseColor,
          onSurface: contrastColor,
          background: baseColor,
          onBackground: contrastColor,
          error: Colors.red.shade600,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: baseColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: contrastColor, fontSize: 16),
          bodyMedium: TextStyle(color: contrastColor, fontSize: 14),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: baseColor,
          foregroundColor: contrastColor,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}
