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

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // GET user document stream
  Stream<DocumentSnapshot> getUserStream() {
    if (_currentUser == null) {
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(_currentUser!.uid).snapshots();
  }

  // ADD a new social link
  Future<void> addLink(Map<String, dynamic> newLink) async {
    if (_currentUser == null) return;
    final userDocRef = _firestore.collection('users').doc(_currentUser!.uid);
    await userDocRef.update({
      'custom_links': FieldValue.arrayUnion([newLink]),
    });
  }

  // EDIT an existing social link
  Future<void> editLink(
    Map<String, dynamic> oldLink,
    Map<String, dynamic> newLink,
  ) async {
    if (_currentUser == null) return;
    final userDocRef = _firestore.collection('users').doc(_currentUser!.uid);
    await userDocRef.update({
      'custom_links': FieldValue.arrayRemove([oldLink]),
    });
    await userDocRef.update({
      'custom_links': FieldValue.arrayUnion([newLink]),
    });
  }
  // ✨ --- NEW: METHOD TO DELETE MULTIPLE LINKS ---
  Future<void> deleteMultipleLinks(
    List<Map<String, dynamic>> linksToDelete,
  ) async {
    if (_currentUser == null) return;
    final userDocRef = _firestore.collection('users').doc(_currentUser!.uid);
    // Use arrayRemove with a list of maps to delete multiple items at once
    await userDocRef.update({
      'custom_links': FieldValue.arrayRemove(linksToDelete),
    });
  }

  // ✨ --- NEW: METHOD TO UPDATE THE ENTIRE LINKS ARRAY (FOR REORDERING) ---
  Future<void> updateLinksOrder(List<dynamic> reorderedLinks) async {
    if (_currentUser == null) return;
    final userDocRef = _firestore.collection('users').doc(_currentUser.uid);
    // Overwrite the existing array with the newly ordered one
    await userDocRef.update({'custom_links': reorderedLinks});
  }
  // DELETE a social link
  Future<void> deleteLink(Map<String, dynamic> linkToDelete) async {
    if (_currentUser == null) return;
    final userDocRef = _firestore.collection('users').doc(_currentUser.uid);
    await userDocRef.update({
      'custom_links': FieldValue.arrayRemove([linkToDelete]),
    });
  }
}
