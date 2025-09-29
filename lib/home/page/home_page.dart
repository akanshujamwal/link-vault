// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:link_vault/auth/auth_service.dart';
// import 'package:link_vault/home/widgets/add_social_link_dialog.dart';
// import 'package:link_vault/home/widgets/animated_exit_dialog.dart';
// import 'package:link_vault/home/widgets/circular_avtar_image.dart';
// import 'package:link_vault/home/widgets/info_card.dart';
// import 'package:link_vault/profile/profile_page.dart';
// import 'package:link_vault/scanner/page/scanner_page.dart';
// import 'package:link_vault/services/firestore_service.dart'; // Import Firestore Service
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final FirestoreService _firestoreService = FirestoreService();
//   bool isDrawerOnRight = false;
//    String qrData = "";
//   int _selectedIndex = -1;

//   // --- Helper function to map icon names to actual Icons ---
//   IconData _getIconForPlatform(String iconName) {
//     switch (iconName) {
//       case 'linkedin':
//         return Icons
//             .link; // Using a generic one, you can use font_awesome_flutter for brand icons
//       case 'github':
//         return Icons.code;
//       case 'twitter':
//         return Icons.chat_bubble;
//       case 'language':
//         return Icons.language;
//       default:
//         return Icons.add_circle;
//     }
//   }

//   Future<void> _showAddLinkDialog() async {
//     await showDialog(
//       context: context,
//       builder: (context) => const AddSocialLinkDialog(),
//     );
//   }

//   // Function to scan QR code
//   Future<void> scanQrCode() async {
//     try {
//       // Navigate to QR Scanner page and get the scanned result
//       final scannedData = await Navigator.of(context).push<String>(
//         MaterialPageRoute(builder: (context) => const QRScannerPage()),
//       );

//       if (scannedData != null) {
//         setState(() {
//           qrData = scannedData;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         qrData = 'Error scanning QR: $e';
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (didPop) return;
//         _showAnimatedExitDialog();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         // --- ADDED FLOATING ACTION BUTTON ---
//         floatingActionButton: FloatingActionButton(
//           onPressed: _showAddLinkDialog,
//           backgroundColor: Colors.white,
//           child: const Icon(Icons.add, color: Colors.black),
//         ),
//         body: Row(
//           children: [
//             if (!isDrawerOnRight) buildDrawer(), // drawer on left
//             Expanded(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Spacer(),
//                     CircularImageAvatar(),
//                     SizedBox(height: 20),
//                     Text(
//                       'Akanshu Jamwal', // This can be replaced with dynamic data later
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         fontSize: 35,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       'Flutter Developer @ JM Financial',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                     SizedBox(height: 20),
//                     ContactInfoCard(),
//                     Spacer(),

//                     IconButton(
//                       onPressed: () {
//                         scanQrCode();
//                       },
//                       icon: Icon(
//                         Icons.qr_code_scanner,
//                         size: 50,
//                         color: Colors.white,
//                       ),
//                     ),

//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ),
//             if (isDrawerOnRight) buildDrawer(), // drawer on right
//           ],
//         ),
//       ),
//     );
//   }
//   Widget buildDrawer() {
//     final authService = AuthService();
//     final user = authService.currentUser;

//     if (user == null) {
//       return Container(width: 80, color: Colors.white);
//     }

//     final Stream<DocumentSnapshot> userDocStream = FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .snapshots();

//     return Container(
//       width: 80,
//       color: Colors.white,
//       child: StreamBuilder<DocumentSnapshot>(
//         stream: userDocStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data?.data() == null) {
//             return _buildDrawerContent([], authService);
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>;
//           final List<dynamic> customLinksData = data['custom_links'] ?? [];

//           final customLinkItems = customLinksData.map((linkData) {
//             return {
//               'icon': _getIconForPlatform(linkData['platform']),
//               'action': 'show_custom_qr',
//               'data': linkData['data'],
//             };
//           }).toList();

//           return _buildDrawerContent(customLinkItems, authService);
//         },
//       ),
//     );
//   }
//   // --- DRAWER IS NOW DYNAMIC ---
//   // Widget buildDrawer() {
//   //   final authService = AuthService();

//   //   return Container(
//   //     width: 80,
//   //     color: Colors.white,
//   //     child: Column(
//   //       children: [
//   //         // Static Top Buttons
//   //         IconButton(
//   //           icon: const Icon(Icons.swap_horiz),
//   //           color: Colors.black,
//   //           iconSize: 30,
//   //           onPressed: () {
//   //             setState(() {
//   //               isDrawerOnRight = !isDrawerOnRight;
//   //             });
//   //           },
//   //         ),
//   //         const Divider(),
//   //         // Dynamic Buttons from Firestore
//   //         Expanded(
//   //           child: StreamBuilder<QuerySnapshot>(
//   //             stream: _firestoreService.getSocialLinksStream(),
//   //             builder: (context, snapshot) {
//   //               if (!snapshot.hasData) {
//   //                 return const Center(child: CircularProgressIndicator());
//   //               }
//   //               if (snapshot.data!.docs.isEmpty) {
//   //                 return const Center(child: Text("No links"));
//   //               }

//   //               return ListView(
//   //                 children: snapshot.data!.docs.map((doc) {
//   //                   final data = doc.data() as Map<String, dynamic>;
//   //                   return IconButton(
//   //                     icon: Icon(_getIconForPlatform(data['iconName'])),
//   //                     color: Colors.black,
//   //                     iconSize: 30,
//   //                     onPressed: () {
//   //                       _showQrDialog(
//   //                         context,
//   //                         data['link'],
//   //                         !isDrawerOnRight ? 80.0 : 0,
//   //                         isDrawerOnRight ? 80.0 : 0,
//   //                       );
//   //                     },
//   //                   );
//   //                 }).toList(),
//   //               );
//   //             },
//   //           ),
//   //         ),
//   //         // Static Bottom Button
//   //         const Divider(),
//   //         IconButton(
//   //           icon: const Icon(Icons.logout),
//   //           color: Colors.redAccent,
//   //           iconSize: 30,
//   //           onPressed: () async {
//   //             await authService.signOut();
//   //           },
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//  Widget _buildDrawerContent(
//       List<Map<String, dynamic>> customItems, AuthService authService) {
//     // 1. Add the new profile button to the list of drawer items
//     final allDrawerItems = [
//       {'icon': Icons.home, 'action': 'navigate_home'},
//       {'icon': Icons.person, 'action': 'view_profile'}, // ✨ NEW BUTTON
//       ...customItems,
//       {'icon': Icons.swap_horiz, 'action': 'swap_drawer'},
//       {'icon': Icons.logout, 'action': 'sign_out'},
//       {'icon': Icons.add_circle, 'action': 'add_link'},
//     ];

//     return ListView.builder(
//       itemCount: allDrawerItems.length,
//       itemBuilder: (context, index) {
//         final item = allDrawerItems[index];
//         final isSelected = _selectedIndex == index;

//         return IconButton(
//           icon: Icon(item['icon'] as IconData),
//           color: isSelected ? Colors.blueAccent : Colors.black,
//           iconSize: 30,
//           onPressed: () async {
//             setState(() => _selectedIndex = index);
//             String action = item['action'] as String;

//             if (action == 'navigate_home') {
//               Navigator.popUntil(context, (route) => route.isFirst);
//             }
//             // 2. Handle the 'view_profile' action by navigating to the ProfilePage
//             else if (action == 'view_profile') { // ✨ NEW ACTION HANDLER
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ProfilePage()),
//               );
//             }
//             else if (action == 'swap_drawer') {
//               setState(() => isDrawerOnRight = !isDrawerOnRight);
//             } else if (action == 'sign_out') {
//               await authService.signOut();
//             } else if (action == 'add_link') {
//               await _showAddLinkDialog();
//             } else if (action == 'show_custom_qr') {
//               await _showQrDialog(
//                 context,
//                 item['data'] as String,
//                 !isDrawerOnRight ? 80.0 : 0,
//                 isDrawerOnRight ? 80.0 : 0,
//               );
//             }
//             if (mounted) {
//               setState(() => _selectedIndex = -1);
//             }
//           },
//         );
//       },
//     );
//   }
//   // --- UNCHANGED METHODS ---
//   Future<void> _showQrDialog(
//     BuildContext context,
//     String data,
//     double leftpadding,
//     double rightpadding,
//   ) async {
//     if (data.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Cannot generate QR code from empty data."),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//       return;
//     }

//     await showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//       transitionDuration: const Duration(milliseconds: 400),
//       pageBuilder: (dialogContext, animation, secondaryAnimation) {
//         final Uri? uri = Uri.tryParse(data);
//         final bool isUrl = uri != null && uri.hasAbsolutePath;

//         return Padding(
//           padding: EdgeInsets.only(left: leftpadding, right: rightpadding),
//           child: AlertDialog(
//             backgroundColor: Colors.white,
//             content: SizedBox(
//               width: 250,
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         GestureDetector(
//                           onTap: () => Navigator.pop(dialogContext),
//                           child: const Icon(Icons.close, color: Colors.red),
//                         ),
//                         const SizedBox(width: 5),
//                         if (isUrl) ...[
//                           GestureDetector(
//                             onTap: () {
//                               Clipboard.setData(ClipboardData(text: data));
//                               Navigator.pop(dialogContext);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text("Text Copied!")),
//                               );
//                             },
//                             child: const Icon(
//                               Icons.copy_outlined,
//                               color: Colors.orange,
//                             ),
//                           ),
//                           const SizedBox(width: 5),
//                           GestureDetector(
//                             onTap: () async {
//                               if (uri != null) {
//                                 await launchUrl(uri);
//                               }
//                             },
//                             child: const Icon(
//                               Icons.open_in_browser_outlined,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ] else ...[
//                           GestureDetector(
//                             onTap: () {
//                               Clipboard.setData(ClipboardData(text: data));
//                               Navigator.pop(dialogContext);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text("Text Copied!")),
//                               );
//                             },
//                             child: const Icon(
//                               Icons.copy_outlined,
//                               color: Colors.orange,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                     QrImageView(
//                       data: data,
//                       size: 200,
//                       version: QrVersions.auto,
//                       dataModuleStyle: const QrDataModuleStyle(
//                         dataModuleShape: QrDataModuleShape.circle,
//                         color: Colors.black,
//                       ),
//                       eyeStyle: const QrEyeStyle(
//                         eyeShape: QrEyeShape.circle,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         return ScaleTransition(
//           scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
//           child: FadeTransition(opacity: animation, child: child),
//         );
//       },
//     );
//   }

//   Future<void> _showAnimatedExitDialog() async {
//     await showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//       transitionDuration: const Duration(milliseconds: 400),
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return const AnimatedExitDialog();
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         return ScaleTransition(
//           scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
//           child: FadeTransition(opacity: animation, child: child),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:link_vault/home/widgets/animated_exit_dialog.dart';
import 'package:link_vault/profile/profile_page.dart';
import 'package:link_vault/scanner/page/scanner_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Page to display all links when "Show More" is tapped
class AllLinksPage extends StatelessWidget {
  final List<dynamic> allLinks;
  final VoidCallback onAdd;
  final Function(String) getIconForPlatform;

  const AllLinksPage({
    super.key,
    required this.allLinks,
    required this.onAdd,
    required this.getIconForPlatform,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('All My Links'),
        backgroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: allLinks.length,
        itemBuilder: (context, index) {
          final item = allLinks[index];
          final IconData icon = getIconForPlatform(item['platform']);
          final String platformName = item['platform'];

          return InkWell(
            onTap: () {
              // In a real app, you might show a QR code or open the link
              print("Tapped on ${item['data']}");
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 35),
                  const SizedBox(height: 8),
                  Text(
                    platformName[0].toUpperCase() + platformName.substring(1),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _onItemTapped(int index) {
    if (index == 1) {
      _scanQrCode();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  Future<void> _scanQrCode() async {
    try {
      await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const QRScannerPage()),
      );
    } catch (e) {
      print('Error scanning QR: $e');
    }
  }

  IconData _getIconForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return Icons.business_center;
      case 'github':
        return Icons.code;
      case 'twitter':
        return Icons.message;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'discord':
        return Icons.chat;
      case 'dev.to':
        return Icons.article;
      case 'hashnode':
        return Icons.notes;
      case 'medium':
        return Icons.article_outlined;
      case 'youtube':
        return Icons.play_circle_filled;
      case 'rssfeed':
        return Icons.rss_feed;
      case 'codepen':
        return Icons.edit;
      case 'codesandbox':
        return Icons.widgets;
      case 'dribbble':
        return Icons.sports_basketball;
      case 'behance':
        return Icons.palette;
      case 'stackoverflow':
        return Icons.question_answer;
      case 'kaggle':
        return Icons.analytics;
      case 'codechef':
        return Icons.emoji_events;
      case 'hackerrank':
        return Icons.star;
      case 'codeforces':
        return Icons.military_tech;
      case 'leetcode':
        return Icons.keyboard;
      case 'topcoder':
        return Icons.leaderboard;
      case 'hackerearth':
        return Icons.public;
      case 'geeksforgeeks':
        return Icons.school;
      case 'website':
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  Future<void> _showAddLinkDialog() async {
    final formKey = GlobalKey<FormState>();
    final linkController = TextEditingController();
    TextEditingController? platformController;

    final List<String> platforms = [
      'Behance',
      'CodeChef',
      'Codeforces',
      'CodePen',
      'CodeSandbox',
      'Dev.to',
      'Discord',
      'Dribbble',
      'Facebook',
      'GeeksforGeeks',
      'GitHub',
      'HackerEarth',
      'HackerRank',
      'Hashnode',
      'Instagram',
      'Kagle',
      'LeetCode',
      'LinkedIn',
      'Medium',
      'RSSFeed',
      'StackOverflow',
      'TopCoder',
      'Twitter',
      'Website',
      'YouTube',
      'Other',
    ];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Link'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return platforms
                        .where((String option) {
                          return option.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                        })
                        .take(3);
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController fieldController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        platformController = fieldController;
                        return TextFormField(
                          controller: fieldController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Platform',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a platform';
                            }
                            if (!platforms.any(
                              (p) => p.toLowerCase() == value.toLowerCase(),
                            )) {
                              return 'Please select a valid platform';
                            }
                            return null;
                          },
                        );
                      },
                ),
                TextFormField(
                  controller: linkController,
                  decoration: const InputDecoration(labelText: 'URL'),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter a URL'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (currentUser == null) return;
                  final String platform = platformController?.text ?? '';
                  final newLink = {
                    'platform': platform.toLowerCase(),
                    'data': linkController.text,
                    'createdAt': Timestamp.now(),
                  };
                  final userDocRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser!.uid);
                  await userDocRef.update({
                    'custom_links': FieldValue.arrayUnion([newLink]),
                  });
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditLinkDialog(Map<String, dynamic> oldLinkData) async {
    final formKey = GlobalKey<FormState>();
    final linkController = TextEditingController(text: oldLinkData['data']);
    final platformController = TextEditingController(
      text: oldLinkData['platform'],
    );

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Link'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: platformController,
                decoration: const InputDecoration(labelText: 'Platform'),
                enabled: false,
              ),
              TextFormField(
                controller: linkController,
                decoration: const InputDecoration(labelText: 'URL'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter a URL'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (currentUser == null) return;

                final newLinkData = {
                  'platform': platformController.text.toLowerCase(),
                  'data': linkController.text,
                  'createdAt': oldLinkData['createdAt'],
                };

                final userDocRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid);
                await userDocRef.update({
                  'custom_links': FieldValue.arrayRemove([oldLinkData]),
                });
                await userDocRef.update({
                  'custom_links': FieldValue.arrayUnion([newLinkData]),
                });

                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLink(Map<String, dynamic> linkData) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link?'),
        content: Text(
          'Are you sure you want to delete your ${linkData['platform']} link?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && currentUser != null) {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid);
      await userDocRef.update({
        'custom_links': FieldValue.arrayRemove([linkData]),
      });
    }
  }

  Future<void> _showQrDialog(BuildContext context, String data) async {
    final Uri? uri = Uri.tryParse(data);
    final bool isUrl =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        content: SizedBox(
          width: 250,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: 200.0,
                  dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
                  eyeStyle: const QrEyeStyle(color: Colors.black),
                ),
                const SizedBox(height: 16),
                Text(
                  data,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (isUrl)
            TextButton(
              child: const Text("OPEN IN BROWSER"),
              onPressed: () async {
                if (uri != null) await launchUrl(uri);
              },
            ),
          TextButton(
            child: const Text("COPY"),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: data));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copied to clipboard!")),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLinkOptionsDialog(Map<String, dynamic> linkData) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: const Color(0xFF1E1E1E),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.qr_code, color: Colors.white),
                title: const Text(
                  'Show QR Code',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showQrDialog(context, linkData['data']);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Edit Link',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditLinkDialog(linkData);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text(
                  'Delete Link',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteLink(linkData);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialGrid(List<dynamic> links) {
    List<dynamic> gridItems = [];
    bool hasMore = links.length > 5;

    if (hasMore) {
      gridItems = links.take(5).toList();
      gridItems.add({'platform': 'show_more'});
    } else {
      gridItems = List.from(links);
      gridItems.add({'platform': 'add_new'});
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: gridItems.length,
        itemBuilder: (context, index) {
          final item = gridItems[index];
          final String platform = item['platform'];

          if (platform == 'add_new') {
            return InkWell(
              onTap: _showAddLinkDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 35),
                    SizedBox(height: 8),
                    Text(
                      "Add New",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          if (platform == 'show_more') {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllLinksPage(
                      allLinks: links,
                      onAdd: _showAddLinkDialog,
                      getIconForPlatform: _getIconForPlatform,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.more_horiz, color: Colors.white, size: 35),
                    SizedBox(height: 8),
                    Text(
                      "Show More",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          final IconData icon = _getIconForPlatform(platform);
          return InkWell(
            onTap: () => _showQrDialog(context, item['data']),
            onLongPress: () => _showLinkOptionsDialog(item),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 35),
                  const SizedBox(height: 8),
                  Text(
                    platform[0].toUpperCase() + platform.substring(1),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeBody(Map<String, dynamic> userData) {
    final String displayName = userData['displayName'] ?? 'No Name';
    final String designation = userData['designation'] ?? 'No Designation';
    final String companyName = userData['companyName'] ?? 'No Company';
    final String photoURL = userData['photoURL'] ?? '';
    final List<dynamic> customLinks = userData['custom_links'] ?? [];

    customLinks.sort(
      (a, b) =>
          (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: photoURL.isNotEmpty
                      ? NetworkImage(photoURL)
                      : null,
                  child: photoURL.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 35,
                  ),
                ),
                const SizedBox(height: 5),
                if (designation.isNotEmpty && companyName.isNotEmpty)
                  Text(
                    '$designation @ $companyName',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                const Spacer(),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "My Links",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: _buildSocialGrid(customLinks)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Not logged in.")));
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (_) => const AnimatedExitDialog(),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  "Could not load profile.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return _buildHomeBody(userData);
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
