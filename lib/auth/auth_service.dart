
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';


// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Stream for auth state changes
//   Stream<User?> get user => _auth.authStateChanges();

//   // Sign in with Google
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         // The user canceled the sign-in
//         return null;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final UserCredential userCredential = await _auth.signInWithCredential(
//         credential,
//       );
//       final User? user = userCredential.user;

//       // After successful sign-in, save user data to Firestore
//       if (user != null) {
//         final DocumentReference userDoc = _firestore
//             .collection('users')
//             .doc(user.uid);

//         final docSnapshot = await userDoc.get();

//         // If the document doesn't exist, it's a new user. Create it.
//         if (!docSnapshot.exists) {
//           await userDoc.set({
//             'uid': user.uid,
//             'displayName': user.displayName,
//             'email': user.email,
//             'photoURL': user.photoURL,
//             'createdAt': FieldValue.serverTimestamp(), // Correct usage
//             'lastLogin': FieldValue.serverTimestamp(), // Correct usage
//           });
//         } else {
//           // If the user already exists, just update their last login time
//           await userDoc.update({'lastLogin': FieldValue.serverTimestamp()});
//         }
//       }

//       return userCredential;
//     } catch (e) {
//       print("Error during Google Sign-In: $e");
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
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add this

  User? get currentUser => _auth.currentUser;
  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // ✨ Check if it's a new user
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          await _createInitialUserProfile(user);
        }
      }
      return userCredential;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // ✨ NEW: Helper method to create the initial user profile document
  Future<void> _createInitialUserProfile(User user) async {
    // Derive a display name from the email
    String derivedName = user.email?.split('@')[0] ?? 'New User';
    // Capitalize first letter of parts
    derivedName = derivedName.replaceAll('.', ' ').split(' ')
      .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'displayName': derivedName,
      'email': user.email,
      'photoURL': user.photoURL ?? '', // Use Google's photo if available
      'designation': '',
      'companyName': '',
      'mobileNumber': '',
    });
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}