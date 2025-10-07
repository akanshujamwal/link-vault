// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:link_vault/auth/auth_gate.dart';
// import 'package:link_vault/auth/auth_service.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final User? currentUser = FirebaseAuth.instance.currentUser;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final AuthService _authService = AuthService();

//   bool _isEditing = false;
//   bool _isUploading = false;

//   late TextEditingController _nameController;
//   late TextEditingController _designationController;
//   late TextEditingController _companyController;
//   late TextEditingController _mobileController;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController();
//     _designationController = TextEditingController();
//     _companyController = TextEditingController();
//     _mobileController = TextEditingController();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     if (currentUser == null) return;
//     final doc = await _firestore
//         .collection('users')
//         .doc(currentUser!.uid)
//         .get();
//     if (doc.exists && mounted) {
//       final data = doc.data() as Map<String, dynamic>;
//       _nameController.text = data['displayName'] ?? '';
//       _designationController.text = data['designation'] ?? '';
//       _companyController.text = data['companyName'] ?? '';
//       _mobileController.text = data['mobileNumber'] ?? '';

//       if (_designationController.text.isEmpty ||
//           _companyController.text.isEmpty ||
//           _mobileController.text.isEmpty) {
//         setState(() {
//           _isEditing = true;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _designationController.dispose();
//     _companyController.dispose();
//     _mobileController.dispose();
//     super.dispose();
//   }

//   Future<void> _signOut() async {
//     await _authService.signOut();
//     if (mounted) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const AuthGate()),
//         (Route<dynamic> route) => false,
//       );
//     }
//   }

//   Future<void> _pickAndUploadImage() async {
//     if (currentUser == null) return;

//     setState(() {
//       _isUploading = true;
//     });

//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 70,
//     );
//     if (image == null) {
//       setState(() {
//         _isUploading = false;
//       });
//       return;
//     }

//     try {
//       final ref = _storage.ref('profile_pictures/${currentUser!.uid}');
//       await ref.putFile(File(image.path));
//       final downloadUrl = await ref.getDownloadURL();
//       await _firestore.collection('users').doc(currentUser!.uid).update({
//         'photoURL': downloadUrl,
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile picture updated!')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (currentUser == null) return;
//     final name = _nameController.text.trim();
//     final designation = _designationController.text.trim();
//     final company = _companyController.text.trim();
//     final mobile = _mobileController.text.trim();

//     if (name.isEmpty ||
//         designation.isEmpty ||
//         company.isEmpty ||
//         mobile.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all required fields.')),
//       );
//       return;
//     }

//     try {
//       await _firestore.collection('users').doc(currentUser!.uid).update({
//         'displayName': name,
//         'designation': designation,
//         'companyName': company,
//         'mobileNumber': mobile,
//       });
//       setState(() {
//         _isEditing = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully!')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
//       }
//     }
//   }

//   InputDecoration _buildInputDecoration(String label) {
//     if (_isEditing) {
//       return InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.amber),
//         filled: true,
//         fillColor: Colors.amber.withOpacity(0.1),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8.0),
//           borderSide: const BorderSide(color: Colors.amber),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8.0),
//           borderSide: const BorderSide(color: Colors.amber, width: 2.0),
//         ),
//       );
//     }
//     return InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(color: Colors.grey.shade400),
//       filled: true,
//       fillColor: Colors.grey.shade900,
//       disabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8.0),
//         borderSide: BorderSide(color: Colors.grey.shade800),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✨ RESPONSIVE: Get screen width for responsive sizing
//     final screenWidth = MediaQuery.of(context).size.width;

//     if (currentUser == null) {
//       return const Scaffold(body: Center(child: Text("Please log in.")));
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text("My Profile"),
//         backgroundColor: Colors.grey.shade900,
//         actions: [
//           _isEditing
//               ? IconButton(
//                   icon: const Icon(Icons.save),
//                   onPressed: _saveProfile,
//                   tooltip: 'Save',
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: () => setState(() => _isEditing = true),
//                   tooltip: 'Edit',
//                 ),
//         ],
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: _firestore
//             .collection('users')
//             .doc(currentUser!.uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text("User profile not found."));
//           }
//           var userData = snapshot.data!.data() as Map<String, dynamic>;
//           final String photoURL = userData['photoURL'] ?? '';

//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//             child: Column(
//               // ✨ RESPONSIVE: Use screen width for padding
//               children: [
//                 const SizedBox(height: 30),
//                 Center(
//                   child: Stack(
//                     children: [
//                       CircleAvatar(
//                         // ✨ RESPONSIVE: Avatar size scales with screen width
//                         radius: screenWidth * 0.2, // e.g., 20% of screen width
//                         backgroundColor: Colors.grey.shade800,
//                         backgroundImage: photoURL.isNotEmpty
//                             ? NetworkImage(photoURL)
//                             : null,
//                         child: photoURL.isEmpty
//                             ? Icon(
//                                 Icons.person,
//                                 size: screenWidth * 0.15,
//                                 color: Colors.grey.shade400,
//                               )
//                             : null,
//                       ),
//                       // ✨ FIX: Restored the camera icon button and ensured it's a direct child of the Stack
//                       if (_isEditing)
//                         Positioned(
//                           bottom: 0,
//                           right: 4,
//                           child: CircleAvatar(
//                             radius: screenWidth * 0.06, // Responsive radius
//                             backgroundColor: Colors.black,
//                             child: CircleAvatar(
//                               radius:
//                                   screenWidth *
//                                   0.055, // Responsive inner radius
//                               backgroundColor: Theme.of(context).primaryColor,
//                               child: _isUploading
//                                   ? const Padding(
//                                       padding: EdgeInsets.all(8.0),
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                   : IconButton(
//                                       icon: Icon(
//                                         Icons.camera_alt,
//                                         color: Colors.white,
//                                         size:
//                                             screenWidth *
//                                             0.05, // Responsive icon size
//                                       ),
//                                       onPressed: _pickAndUploadImage,
//                                     ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 TextFormField(
//                   initialValue: userData['email'] ?? 'No email',
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     labelStyle: TextStyle(color: Colors.grey.shade400),
//                     filled: true,
//                     fillColor: Colors.grey.shade900,
//                     disabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide: BorderSide(color: Colors.grey.shade800),
//                     ),
//                   ),
//                   enabled: false,
//                   style: TextStyle(color: Colors.grey.shade400),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: _buildInputDecoration('Display Name'),
//                   enabled: _isEditing,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _designationController,
//                   decoration: _buildInputDecoration('Designation'),
//                   enabled: _isEditing,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _companyController,
//                   decoration: _buildInputDecoration('Company Name'),
//                   enabled: _isEditing,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _mobileController,
//                   decoration: _buildInputDecoration('Mobile Number'),
//                   keyboardType: TextInputType.phone,
//                   enabled: _isEditing,
//                 ),
//                 // ✨ UI UPDATE: Increased the spacer size for better separation
//                 const Spacer(),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.logout, color: Colors.white),
//                     label: const Text(
//                       'LOGOUT',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onPressed: _signOut,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.redAccent.withOpacity(0.8),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_vault/auth/auth_gate.dart';
import 'package:link_vault/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  bool _isEditing = false;
  bool _isUploading = false;
  bool _initialLoad = true; // To check if it's the first data load

  late final TextEditingController _nameController;
  late final TextEditingController _designationController;
  late final TextEditingController _companyController;
  late final TextEditingController _mobileController;

  // ✨ FIX 1: Define the stream as a state variable.
  // This will be initialized once and reused across rebuilds.
  Stream<DocumentSnapshot>? _userStream;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _designationController = TextEditingController();
    _companyController = TextEditingController();
    _mobileController = TextEditingController();

    // ✨ FIX 1: Initialize the stream ONCE in initState.
    // This prevents creating a new stream on every build.
    if (currentUser != null) {
      _userStream = _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _companyController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (currentUser == null) return;

    setState(() {
      _isUploading = true;
    });

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
      return;
    }

    try {
      final ref = _storage.ref('profile_pictures/${currentUser!.uid}');
      await ref.putFile(File(image.path));
      final downloadUrl = await ref.getDownloadURL();
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'photoURL': downloadUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (currentUser == null) return;
    final name = _nameController.text.trim();
    final designation = _designationController.text.trim();
    final company = _companyController.text.trim();
    final mobile = _mobileController.text.trim();

    if (name.isEmpty ||
        designation.isEmpty ||
        company.isEmpty ||
        mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'displayName': name,
        'designation': designation,
        'companyName': company,
        'mobileNumber': mobile,
      });
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    if (_isEditing) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        filled: true,
        fillColor: Colors.amber.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.amber),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.amber, width: 2.0),
        ),
      );
    }
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade900,
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.grey.shade900,
        actions: [
          _isEditing
              ? IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveProfile,
                  tooltip: 'Save',
                )
              : IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => setState(() => _isEditing = true),
                  tooltip: 'Edit',
                ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // ✨ FIX 1: Use the state variable for the stream.
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _initialLoad) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User profile not found."));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          // ✨ FIX 2: Sync controllers with stream data ONLY when not editing.
          // This keeps the displayed data fresh but doesn't overwrite user input.
          if (!_isEditing) {
            _nameController.text = userData['displayName'] ?? '';
            _designationController.text = userData['designation'] ?? '';
            _companyController.text = userData['companyName'] ?? '';
            _mobileController.text = userData['mobileNumber'] ?? '';
          }

          // ✨ FIX 3: Check for empty fields on the first data load to force editing mode.
          if (_initialLoad && snapshot.hasData) {
            final designation = userData['designation'] ?? '';
            final company = userData['companyName'] ?? '';
            final mobile = userData['mobileNumber'] ?? '';

            if (designation.isEmpty || company.isEmpty || mobile.isEmpty) {
              // Safely call setState after the build is complete.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isEditing = true;
                  });
                }
              });
            }
            _initialLoad = false; // Ensure this check only runs once
          }

          final String photoURL = userData['photoURL'] ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.2,
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage: photoURL.isNotEmpty
                            ? NetworkImage(photoURL)
                            : null,
                        child: photoURL.isEmpty
                            ? Icon(
                                Icons.person,
                                size: screenWidth * 0.15,
                                color: Colors.grey.shade400,
                              )
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: CircleAvatar(
                            radius: screenWidth * 0.06,
                            backgroundColor: Colors.black,
                            child: CircleAvatar(
                              radius: screenWidth * 0.055,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: _isUploading
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: screenWidth * 0.05,
                                      ),
                                      onPressed: _pickAndUploadImage,
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  // Use a Key with the email value to ensure it rebuilds if the email changes
                  key: ValueKey(userData['email']),
                  initialValue: userData['email'] ?? 'No email',
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                  ),
                  enabled: false,
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Display Name'),
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _designationController,
                  decoration: _buildInputDecoration('Designation'),
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyController,
                  decoration: _buildInputDecoration('Company Name'),
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileController,
                  decoration: _buildInputDecoration('Mobile Number'),
                  keyboardType: TextInputType.phone,
                  enabled: _isEditing,
                ),
                Spacer(),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'LOGOUT',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
