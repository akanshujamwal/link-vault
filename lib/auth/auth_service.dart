
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