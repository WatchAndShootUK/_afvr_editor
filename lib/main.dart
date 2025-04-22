import 'package:afvr_editor/globals.dart';
import 'package:flutter/material.dart';
import 'ui/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFVR Editor',
      theme: ThemeData(
        primaryColor: khakiBrown,
        colorScheme: ColorScheme.fromSeed(
          seedColor: khakiBrown,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: khakiBrown,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: khakiBrown,
            foregroundColor: Colors.white,
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: khakiBrown,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
