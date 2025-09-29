// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:link_vault/home/page/home_page.dart';
// // import 'package:link_vault/scanner/page/generate_qr_code_page.dart';
// // import 'package:link_vault/scanner/page/scanner_page.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();

// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       initialRoute: '/',
// //       routes: {
// //         '/': (context) => HomePage(),
// //         '/scanner': (context) => QRScannerPage(),
// //         '/generate': (context) => GenerateQrCodePage(),
// //       },
// //     );
// //   }
// // }
// // main.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:link_vault/auth/auth_gate.dart'; // Import the new gate
// import 'package:link_vault/home/page/home_page.dart';
// import 'package:link_vault/scanner/page/generate_qr_code_page.dart';
// import 'package:link_vault/scanner/page/scanner_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       // The AuthGate now decides which page to show
//       home: const AuthGate(),
//       routes: {
//         // You can keep your named routes for navigation after login
//         '/home': (context) => const HomePage(),
//         '/scanner': (context) => const QRScannerPage(),
//         '/generate': (context) => const GenerateQrCodePage(),
//       },
//     );
//   }
// }
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:link_vault/auth/auth_gate.dart'; // Import the new gate
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      ),
      // ✨ Use AuthGate as the home screen
      home: const AuthGate(),
    );
  }
}