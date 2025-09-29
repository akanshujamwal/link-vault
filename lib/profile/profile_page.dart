// lib/profile/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_vault/home/page/home_page.dart';
 // Import HomePage for navigation

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isEditing = true; // Start in editing mode by default

  // Controllers for the text fields
  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _companyController;
  late TextEditingController _mobileController;

  String _photoURL = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _designationController = TextEditingController();
    _companyController = TextEditingController();
    _mobileController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _companyController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    if (currentUser == null) return;

    // 1. Pick image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // 2. Upload to Firebase Storage
    try {
      final String fileExtension = image.path.split('.').last;
      final Reference ref = _storage.ref('profile_pictures/${currentUser!.uid}.$fileExtension');
      await ref.putFile(File(image.path));
      final String downloadUrl = await ref.getDownloadURL();

      // 3. Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'photoURL': downloadUrl,
      });

      // Update local state to show new image instantly
      setState(() {
        _photoURL = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  // ✨ MODIFIED METHOD: Includes validation and navigation
  Future<void> _saveProfile() async {
    if (currentUser == null) return;

    // Get text from controllers
    final String name = _nameController.text.trim();
    final String designation = _designationController.text.trim();
    final String company = _companyController.text.trim();
    final String mobile = _mobileController.text.trim();

    // 1. Check if the fields are filled before saving
    if (name.isEmpty || designation.isEmpty || company.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all the required fields to continue.')),
      );
      return; // Stop the save if fields are empty
    }

    try {
      // 2. Update the document in Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'displayName': name,
        'designation': designation,
        'companyName': company,
        'mobileNumber': mobile,
      });

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );

      // 3. Navigate to HomePage after a successful save
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false, // This removes all previous routes
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        actions: [
          // The save button is always visible now
          IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            _firestore.collection('users').doc(currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text("Loading profile..."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          // Set initial values for controllers only once
          _nameController.text = userData['displayName'] ?? '';
          _designationController.text = userData['designation'] ?? '';
          _companyController.text = userData['companyName'] ?? '';
          _mobileController.text = userData['mobileNumber'] ?? '';
          
          // Use a local variable for photo URL to avoid issues during build
          final String currentPhotoURL = userData['photoURL'] ?? '';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: currentPhotoURL.isNotEmpty
                          ? NetworkImage(currentPhotoURL)
                          : null,
                      child: currentPhotoURL.isEmpty
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                          onPressed: _pickAndUploadImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Email (Not Editable)
              TextFormField(
                initialValue: userData['email'] ?? 'No email',
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                enabled: false,
              ),
              const SizedBox(height: 16),
              // All fields are now enabled by default
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Display Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                    labelText: 'Designation', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                    labelText: 'Company Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                    labelText: 'Mobile Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
            ],
          );
        },
      ),
    );
  }
}