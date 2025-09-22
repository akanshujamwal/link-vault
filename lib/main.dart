import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:link_vault/home/page/home_page.dart';
import 'package:link_vault/scanner/page/generate_qr_code_page.dart';
import 'package:link_vault/scanner/page/scanner_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/scanner': (context) => QRScannerPage(),
        '/generate': (context) => GenerateQrCodePage(),
      },
    );
  }
}
