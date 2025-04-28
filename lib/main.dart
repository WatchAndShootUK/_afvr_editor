import 'package:afvr_editor/globals.dart';
import 'package:afvr_editor/services/get_token.dart';
import 'package:afvr_editor/widgets/password_gate.dart';
import 'package:flutter/material.dart';
import 'ui/home_page.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before using async things

  token = await fetchGitHubToken(); // Wait until token is ready
  runApp(
    MaterialApp(
      home: PasswordGate(
        child: MyApp(), // your real app goes here
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorObservers: [routeObserver],
      title: 'AFVR Editor',
      theme: ThemeData(
        primaryColor: wasdColour,
        colorScheme: ColorScheme.fromSeed(
          seedColor: wasdColour,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: wasdColour,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: wasdColour,
            foregroundColor: Colors.white,
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: wasdColour,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
