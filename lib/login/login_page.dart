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
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Link Vault',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.login,
              ), // Replace with a Google icon if you have the package
              label: const Text('Sign in with Google'),
              onPressed: () async {
                await authService.signInWithGoogle();
                // The AuthGate will handle navigation automatically
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
