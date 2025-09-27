import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's UID
  String? get currentUserId => _auth.currentUser?.uid;

  // Add a new social link to the user's collection
  Future<void> addSocialLink({
    required String platform,
    required String link,
    required String iconName, // We'll save a name to map to an icon later
  }) async {
    if (currentUserId == null) return;

    final collection = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('socialLinks');

    await collection.add({
      'platform': platform,
      'link': link,
      'iconName': iconName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get a stream of the user's social links
  Stream<QuerySnapshot> getSocialLinksStream() {
    if (currentUserId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('socialLinks')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }
}
