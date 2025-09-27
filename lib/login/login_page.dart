// lib/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:link_vault/auth/auth_service.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = AuthService();
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Welcome to Link Vault',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton.icon(
//               onPressed: () {
//                 authService.signInWithGoogle();
//               },
//               icon: Icon(Icons.login),

//               // Image.asset(
//               //   'assets/google_logo.png',
//               //   height: 24.0,
//               // ), // Add a Google logo to your assets
//               label: const Text('Sign in with Google'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Link Vault',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                authService.signInWithGoogle();
              },
              // Remember to add a Google logo to your assets folder
              // icon: Image.asset('assets/google_logo.png', height: 24.0),
              icon: const Icon(Icons.login), // Placeholder icon
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
