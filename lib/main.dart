import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/pages/home_page.dart';

void main() async {
  
  await Hive.initFlutter();

  var box = await Hive.openBox('mybox');

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfff8f9fa),
      ),
      home: const HomePage(),
    );
  }
}
