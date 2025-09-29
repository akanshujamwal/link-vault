
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:link_vault/home/page/home_page.dart';
// import 'package:link_vault/login/login_page.dart';
// import 'package:link_vault/spalsh/splash_page.dart';

// class AuthGate extends StatefulWidget {
//   const AuthGate({super.key});

//   @override
//   State<AuthGate> createState() => _AuthGateState();
// }

// class _AuthGateState extends State<AuthGate> {
//   // This flag is just to demonstrate the splash screen on hot reload
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
//     // Show splash screen during the hot reload delay
//     if (_showSplashForHotReload) {
//       return const SplashScreen();
//     }

//     // After the delay, proceed with the normal authentication check
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // Show splash screen while waiting for the initial auth state from Firebase
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SplashScreen();
//         }

//         // User is not logged in, show login page
//         if (!snapshot.hasData) {
//           return const LoginPage();
//         }

//         // User is logged in, show home page
//         return const HomePage();
//       },
//     );
//   }
// }
// lib/auth/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/home/page/home_page.dart';
import 'package:link_vault/login/login_page.dart';
import 'package:link_vault/profile/profile_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User is not logged in
          if (!snapshot.hasData) {
            return const LoginPage(); // Or whatever your login screen is
          }

          // User is logged in, now check profile completion
          return ProfileCompletionCheck(user: snapshot.data!);
        },
      ),
    );
  }
}

class ProfileCompletionCheck extends StatelessWidget {
  final User user;
  const ProfileCompletionCheck({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong."));
        }
        
        // Data received, now check the fields
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          
          final String designation = userData['designation'] ?? '';
          final String companyName = userData['companyName'] ?? '';
          final String mobileNumber = userData['mobileNumber'] ?? '';

          // If any of the required fields are empty, profile is incomplete
          if (designation.isEmpty || companyName.isEmpty || mobileNumber.isEmpty) {
            return const ProfilePage(); // Force user to the profile page
          } else {
            return const HomePage(); // Profile is complete, go to home
          }
        }
        
        // Fallback: If document doesn't exist, something is wrong, send to profile.
        return const ProfilePage();
      },
    );
  }
}