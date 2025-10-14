
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
            return const LoginPage();
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
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
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
          if (designation.isEmpty ||
              companyName.isEmpty ||
              mobileNumber.isEmpty) {
            return const ProfilePage(); // Force user to the profile page
          } else {
            return const HomePage(); // Profile is complete, go to home
          }
        }

        // Fallback: If document doesn't exist, send to profile page to create it.
        return const ProfilePage();
      },
    );
  }
}
