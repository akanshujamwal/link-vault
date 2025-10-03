
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:link_vault/auth/auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Vault',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark, // A dark theme base
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black12),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black12,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
