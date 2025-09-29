
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_vault/auth/auth_service.dart';
import 'package:link_vault/home/widgets/add_social_link_dialog.dart';
import 'package:link_vault/home/widgets/animated_exit_dialog.dart';
import 'package:link_vault/home/widgets/circular_avtar_image.dart';
import 'package:link_vault/home/widgets/info_card.dart';
import 'package:link_vault/profile/profile_page.dart';
import 'package:link_vault/scanner/page/scanner_page.dart';
import 'package:link_vault/services/firestore_service.dart'; // Import Firestore Service
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool isDrawerOnRight = false;
   String qrData = ""; 
  int _selectedIndex = -1;

  // --- Helper function to map icon names to actual Icons ---
  IconData _getIconForPlatform(String iconName) {
    switch (iconName) {
      case 'linkedin':
        return Icons
            .link; // Using a generic one, you can use font_awesome_flutter for brand icons
      case 'github':
        return Icons.code;
      case 'twitter':
        return Icons.chat_bubble;
      case 'language':
        return Icons.language;
      default:
        return Icons.add_circle;
    }
  }

  Future<void> _showAddLinkDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const AddSocialLinkDialog(),
    );
  }

  // Function to scan QR code
  Future<void> scanQrCode() async {
    try {
      // Navigate to QR Scanner page and get the scanned result
      final scannedData = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const QRScannerPage()),
      );

      if (scannedData != null) {
        setState(() {
          qrData = scannedData;
        });
      }
    } catch (e) {
      setState(() {
        qrData = 'Error scanning QR: $e';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showAnimatedExitDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // --- ADDED FLOATING ACTION BUTTON ---
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddLinkDialog,
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.black),
        ),
        body: Row(
          children: [
            if (!isDrawerOnRight) buildDrawer(), // drawer on left
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    CircularImageAvatar(),
                    SizedBox(height: 20),
                    Text(
                      'Akanshu Jamwal', // This can be replaced with dynamic data later
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 35,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Flutter Developer @ JM Financial',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    ContactInfoCard(),
                    Spacer(),

                    IconButton(
                      onPressed: () {
                        scanQrCode();
                      },
                      icon: Icon(
                        Icons.qr_code_scanner,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            if (isDrawerOnRight) buildDrawer(), // drawer on right
          ],
        ),
      ),
    );
  }
  Widget buildDrawer() {
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) {
      return Container(width: 80, color: Colors.white);
    }

    final Stream<DocumentSnapshot> userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    return Container(
      width: 80,
      color: Colors.white,
      child: StreamBuilder<DocumentSnapshot>(
        stream: userDocStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return _buildDrawerContent([], authService);
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> customLinksData = data['custom_links'] ?? [];

          final customLinkItems = customLinksData.map((linkData) {
            return {
              'icon': _getIconForPlatform(linkData['platform']),
              'action': 'show_custom_qr',
              'data': linkData['data'],
            };
          }).toList();

          return _buildDrawerContent(customLinkItems, authService);
        },
      ),
    );
  }
  // --- DRAWER IS NOW DYNAMIC ---
  // Widget buildDrawer() {
  //   final authService = AuthService();

  //   return Container(
  //     width: 80,
  //     color: Colors.white,
  //     child: Column(
  //       children: [
  //         // Static Top Buttons
  //         IconButton(
  //           icon: const Icon(Icons.swap_horiz),
  //           color: Colors.black,
  //           iconSize: 30,
  //           onPressed: () {
  //             setState(() {
  //               isDrawerOnRight = !isDrawerOnRight;
  //             });
  //           },
  //         ),
  //         const Divider(),
  //         // Dynamic Buttons from Firestore
  //         Expanded(
  //           child: StreamBuilder<QuerySnapshot>(
  //             stream: _firestoreService.getSocialLinksStream(),
  //             builder: (context, snapshot) {
  //               if (!snapshot.hasData) {
  //                 return const Center(child: CircularProgressIndicator());
  //               }
  //               if (snapshot.data!.docs.isEmpty) {
  //                 return const Center(child: Text("No links"));
  //               }

  //               return ListView(
  //                 children: snapshot.data!.docs.map((doc) {
  //                   final data = doc.data() as Map<String, dynamic>;
  //                   return IconButton(
  //                     icon: Icon(_getIconForPlatform(data['iconName'])),
  //                     color: Colors.black,
  //                     iconSize: 30,
  //                     onPressed: () {
  //                       _showQrDialog(
  //                         context,
  //                         data['link'],
  //                         !isDrawerOnRight ? 80.0 : 0,
  //                         isDrawerOnRight ? 80.0 : 0,
  //                       );
  //                     },
  //                   );
  //                 }).toList(),
  //               );
  //             },
  //           ),
  //         ),
  //         // Static Bottom Button
  //         const Divider(),
  //         IconButton(
  //           icon: const Icon(Icons.logout),
  //           color: Colors.redAccent,
  //           iconSize: 30,
  //           onPressed: () async {
  //             await authService.signOut();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
 Widget _buildDrawerContent(
      List<Map<String, dynamic>> customItems, AuthService authService) {
    // 1. Add the new profile button to the list of drawer items
    final allDrawerItems = [
      {'icon': Icons.home, 'action': 'navigate_home'},
      {'icon': Icons.person, 'action': 'view_profile'}, // ✨ NEW BUTTON
      ...customItems,
      {'icon': Icons.swap_horiz, 'action': 'swap_drawer'},
      {'icon': Icons.logout, 'action': 'sign_out'},
      {'icon': Icons.add_circle, 'action': 'add_link'},
    ];

    return ListView.builder(
      itemCount: allDrawerItems.length,
      itemBuilder: (context, index) {
        final item = allDrawerItems[index];
        final isSelected = _selectedIndex == index;

        return IconButton(
          icon: Icon(item['icon'] as IconData),
          color: isSelected ? Colors.blueAccent : Colors.black,
          iconSize: 30,
          onPressed: () async {
            setState(() => _selectedIndex = index);
            String action = item['action'] as String;

            if (action == 'navigate_home') {
              Navigator.popUntil(context, (route) => route.isFirst);
            } 
            // 2. Handle the 'view_profile' action by navigating to the ProfilePage
            else if (action == 'view_profile') { // ✨ NEW ACTION HANDLER
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            } 
            else if (action == 'swap_drawer') {
              setState(() => isDrawerOnRight = !isDrawerOnRight);
            } else if (action == 'sign_out') {
              await authService.signOut();
            } else if (action == 'add_link') {
              await _showAddLinkDialog();
            } else if (action == 'show_custom_qr') {
              await _showQrDialog(
                context,
                item['data'] as String,
                !isDrawerOnRight ? 80.0 : 0,
                isDrawerOnRight ? 80.0 : 0,
              );
            }
            if (mounted) {
              setState(() => _selectedIndex = -1);
            }
          },
        );
      },
    );
  }
  // --- UNCHANGED METHODS ---
  Future<void> _showQrDialog(
    BuildContext context,
    String data,
    double leftpadding,
    double rightpadding,
  ) async {
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot generate QR code from empty data."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final Uri? uri = Uri.tryParse(data);
        final bool isUrl = uri != null && uri.hasAbsolutePath;

        return Padding(
          padding: EdgeInsets.only(left: leftpadding, right: rightpadding),
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: SizedBox(
              width: 250,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: const Icon(Icons.close, color: Colors.red),
                        ),
                        const SizedBox(width: 5),
                        if (isUrl) ...[
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: data));
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Text Copied!")),
                              );
                            },
                            child: const Icon(
                              Icons.copy_outlined,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () async {
                              if (uri != null) {
                                await launchUrl(uri);
                              }
                            },
                            child: const Icon(
                              Icons.open_in_browser_outlined,
                              color: Colors.green,
                            ),
                          ),
                        ] else ...[
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: data));
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Text Copied!")),
                              );
                            },
                            child: const Icon(
                              Icons.copy_outlined,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ],
                    ),
                    QrImageView(
                      data: data,
                      size: 200,
                      version: QrVersions.auto,
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Colors.black,
                      ),
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  Future<void> _showAnimatedExitDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const AnimatedExitDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
