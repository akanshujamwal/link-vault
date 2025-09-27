// lib/auth/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:link_vault/home/page/home_page.dart';
import 'package:link_vault/login/login_page.dart';
import 'package:link_vault/spalsh/splash_page.dart';

// class AuthGate extends StatefulWidget {
//   const AuthGate({super.key});

//   @override
//   State<AuthGate> createState() => _AuthGateState();
// }

// class _AuthGateState extends State<AuthGate> {
//   bool _showSplashForHotReload = true;

//   @override
//   void initState() {
//     super.initState();
//     // This timer will show the splash screen for 2 seconds on hot reload
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() {
//           _showSplashForHotReload = false;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // If the flag is true, show the splash screen
//     if (_showSplashForHotReload) {
//       return const SplashScreen();
//     }

//     // After the delay, proceed with the normal authentication check
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // This still handles the initial cold boot loading correctly
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SplashScreen();
//         }

//         if (!snapshot.hasData) {
//           return const LoginPage();
//         }

//         return const HomePage();
//       },
//     );
//   }
// }


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // This flag is just to demonstrate the splash screen on hot reload
  bool _showSplashForHotReload = true;

  @override
  void initState() {
    super.initState();
    // This timer will show the splash screen for 2 seconds on hot reload
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplashForHotReload = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen during the hot reload delay
    if (_showSplashForHotReload) {
      return const SplashScreen();
    }

    // After the delay, proceed with the normal authentication check
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash screen while waiting for the initial auth state from Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // User is not logged in, show login page
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // User is logged in, show home page
        return const HomePage();
      },
    );
  }
}
