// // lib/auth/auth_service.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   // Stream for auth state changes
//   Stream<User?> get user => _auth.authStateChanges();

//   // Sign in with Google
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // Trigger the authentication flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       // Obtain the auth details from the request
//       if (googleUser == null) {
//         // The user canceled the sign-in
//         return null;
//       }
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       // Create a new credential
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Once signed in, return the UserCredential
//       return await _auth.signInWithCredential(credential);
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }
// lib/auth/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      // After successful sign-in, save user data to Firestore
      if (user != null) {
        final DocumentReference userDoc = _firestore
            .collection('users')
            .doc(user.uid);

        final docSnapshot = await userDoc.get();

        // If the document doesn't exist, it's a new user. Create it.
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(), // Correct usage
            'lastLogin': FieldValue.serverTimestamp(), // Correct usage
          });
        } else {
          // If the user already exists, just update their last login time
          await userDoc.update({'lastLogin': FieldValue.serverTimestamp()});
        }
      }

      return userCredential;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
