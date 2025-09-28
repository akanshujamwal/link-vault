// // import 'package:flutter/material.dart';
// // import 'package:link_vault/scanner/page/scanner_page.dart';

// // class HomePage extends StatefulWidget {
// //   const HomePage({super.key});

// //   @override
// //   State<HomePage> createState() => _HomePageState();
// // }

// // class _HomePageState extends State<HomePage> {
// //   String qrData = "Hello, World!"; // Initial value

// //   // Function to scan QR code
// //   Future<void> scanQrCode() async {
// //     try {
// //       // Navigate to QR Scanner page and get the scanned result
// //       final scannedData = await Navigator.of(context).push<String>(
// //         MaterialPageRoute(builder: (context) => const QRScannerPage()),
// //       );

// //       if (scannedData != null) {
// //         setState(() {
// //           qrData = scannedData;
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         qrData = 'Error scanning QR: $e';
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Home Page')),
// //       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: scanQrCode,
// //         child: const Icon(Icons.qr_code_scanner, size: 50),
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             ElevatedButton(
// //               onPressed: () {
// //                 Navigator.pushNamed(context, '/generate');
// //               },
// //               child: const Text("Generate QR code"),
// //             ),
// //             const SizedBox(height: 20),
// //             Text('Scanned QR: $qrData'),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:link_vault/auth/auth_service.dart';
// import 'package:link_vault/home/widgets/animated_exit_dialog.dart';
// import 'package:link_vault/home/widgets/circular_avtar_image.dart';
// import 'package:link_vault/home/widgets/info_card.dart';
// import 'package:link_vault/scanner/page/scanner_page.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String qrData = "Hello, World!"; // Initial value
//   bool isDrawerOnRight = false;
//   final String phoneNumber = '+91 9682685643';
//   int _selectedIndex = -1; // control drawer position

  // // Function to scan QR code
  // Future<void> scanQrCode() async {
  //   try {
  //     // Navigate to QR Scanner page and get the scanned result
  //     final scannedData = await Navigator.of(context).push<String>(
  //       MaterialPageRoute(builder: (context) => const QRScannerPage()),
  //     );

  //     if (scannedData != null) {
  //       setState(() {
  //         qrData = scannedData;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       qrData = 'Error scanning QR: $e';
  //     });
  //   }
  // }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false, // Prevents the app from closing automatically
//       onPopInvoked: (didPop) {
//         // If a pop was not prevented, we don't need to do anything
//         if (didPop) return;
//         // Otherwise, show the exit confirmation dialog
//         _showAnimatedExitDialog();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,

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
//                     const SizedBox(height: 20),
//                     Text(
//                       'Akanshu Jamwal',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         fontSize: 35,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: 'Flutter Developer ',
//                             style: Theme.of(context).textTheme.bodyMedium
//                                 ?.copyWith(
//                                   // fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                 ),
//                           ),
//                           TextSpan(
//                             text: '@ JM Financial',
//                             style: Theme.of(context).textTheme.bodyMedium
//                                 ?.copyWith(
//                                   // fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontStyle: FontStyle.italic,
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           WidgetSpan(
//                             // Use WidgetSpan to include a widget within the text flow
//                             // alignment: PlaceholderAlignment
//                             //     .middle, // Helps vertically align icon and text
//                             child: Icon(
//                               Icons.location_pin,
//                               size:
//                                   25, // Matching size with font for better alignment
//                               color: Colors.white,
//                             ),
//                           ),
//                           TextSpan(
//                             text: ' Mumbai',
//                             style: Theme.of(context).textTheme.bodyMedium
//                                 ?.copyWith(
//                                   // fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   fontSize: 21,
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ContactInfoCard(),
// Spacer(),
// IconButton(
//   onPressed: () {
//     scanQrCode();
//   },
//   icon: Icon(
//     Icons.qr_code_scanner,
//     size: 50,
//     color: Colors.white,
//   ),
// ),

// const SizedBox(height: 30),

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
//     // Define your drawer items here for easy management
//     final drawerItems = [
//       {'icon': Icons.home, 'action': 'navigate_home'},
//       {'icon': Icons.settings_applications, 'action': 'show_qr_dialog'},
//       {'icon': Icons.swap_horiz, 'action': 'swap_drawer'},
//       {'icon': Icons.logout, 'action': 'sign_out'},
//       // ✨ To add more buttons, just add a new map to this list!
//       // {'icon': Icons.info, 'action': 'show_info_dialog'},
//     ];

//     return Container(
//       width: 80,
//       color: Colors.white,
//       child: Builder(
//         builder: (drawerContext) {
//           return ListView.builder(
//             itemCount: drawerItems.length,
//             itemBuilder: (context, index) {
//               final item = drawerItems[index];
//               final isSelected = _selectedIndex == index;

//               return IconButton(
//                 icon: Icon(item['icon'] as IconData),
//                 // ✅ Set color based on selection state
//                 color: isSelected ? Colors.blueAccent : Colors.black,
//                 iconSize: 30,
//                 onPressed: () async {
//                   // Set the state to highlight the button immediately
//                   setState(() {
//                     _selectedIndex = index;
//                   });

//                   // --- Perform the action for the tapped button ---
//                   if (item['action'] == 'navigate_home') {
//                     Navigator.popUntil(drawerContext, (route) => route.isFirst);
//                   } else if (item['action'] == 'show_qr_dialog') {
//                     // ✅ Wait for the dialog to be closed
//                     await _showQrDialog(
//                       drawerContext,
//                       "https://www.linkedin.com/in/akanshu-jamwal/",
//                       !isDrawerOnRight ? 80.0 : 0,
//                       isDrawerOnRight ? 80.0 : 0,
//                     );
//                   } else if (item['action'] == 'swap_drawer') {
//                     setState(() {
//                       isDrawerOnRight = !isDrawerOnRight;
//                     });
//                   } else if (item['action'] == 'sign_out') {
//                     await authService.signOut(); // Call sign out method
//                   }

//                   // ✅ After the action is complete (or dialog is closed),
//                   // reset the selection state.
//                   // The 'mounted' check is a safety measure for async operations.
//                   if (mounted) {
//                     setState(() {
//                       _selectedIndex = -1;
//                     });
//                   }
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // The function signature MUST be 'async' to use 'await'

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

//     // We use showGeneralDialog instead of showDialog for custom animations
//     await showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//       transitionDuration: const Duration(
//         milliseconds: 400,
//       ), // Controls animation speed
//       // This builder returns the dialog widget itself
//       pageBuilder: (dialogContext, animation, secondaryAnimation) {
//         final Uri? uri = Uri.tryParse(data);
//         final bool isUrl = uri != null && uri.hasAbsolutePath;

//         return Padding(
//           padding: EdgeInsets.only(left: leftpadding, right: rightpadding),
//           child: AlertDialog(
//             backgroundColor: Colors.white,

//             // contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
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
//                           child: Container(
//                             child: const Icon(Icons.close, color: Colors.red),
//                           ),
//                         ),
//                         SizedBox(width: 5),
//                         if (isUrl) ...[
//                           GestureDetector(
//                             onTap: () {
//                               Clipboard.setData(ClipboardData(text: data));
//                               Navigator.pop(dialogContext);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text("Text Copied!")),
//                               );
//                             },
//                             child: Container(
//                               child: const Icon(
//                                 Icons.copy_outlined,
//                                 color: Colors.orange,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 5),
//                           GestureDetector(
//                             onTap: () async {
//                               if (uri != null) {
//                                 await launchUrl(uri);
//                               }
//                             },
//                             child: Container(
//                               child: const Icon(
//                                 Icons.open_in_browser_outlined,
//                                 color: Colors.green,
//                               ),
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
//                             child: Container(
//                               child: const Icon(
//                                 Icons.copy_outlined,
//                                 color: Colors.orange,
//                               ),
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
//                     // Text(
//                     //   data,
//                     //   textAlign: TextAlign.center,
//                     //   style: const TextStyle(
//                     //     fontSize: 16,
//                     //     color: Colors.black87,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             ),
//             // actions: [
//             //   if (isUrl) ...[
//             //     TextButton(
//             //       child: const Text("COPY URL"),
//             //       onPressed: () {
//             //         Clipboard.setData(ClipboardData(text: data));
//             //         Navigator.pop(dialogContext);
//             //         ScaffoldMessenger.of(context).showSnackBar(
//             //           const SnackBar(content: Text("URL Copied!")),
//             //         );
//             //       },
//             //     ),
//             //     TextButton(
//             //       child: const Text("OPEN"),
//             //       onPressed: () async {
//             //         if (uri != null) {
//             //           await launchUrl(uri);
//             //         }
//             //       },
//             //     ),
//             //   ] else ...[
//             //     TextButton(
//             //       child: const Text("COPY TEXT"),
//             //       onPressed: () {
//             //         Clipboard.setData(ClipboardData(text: data));
//             //         Navigator.pop(dialogContext);
//             //         ScaffoldMessenger.of(context).showSnackBar(
//             //           const SnackBar(content: Text("Text Copied!")),
//             //         );
//             //       },
//             //     ),
//             //   ],
//             //   TextButton(
//             //     child: const Text("CLOSE"),
//             //     onPressed: () => Navigator.pop(dialogContext),
//             //   ),
//             // ],
//           ),
//         );
//       },

//       // This builder wraps the dialog with our desired animations
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         return ScaleTransition(
//           scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
//           child: FadeTransition(opacity: animation, child: child),
//         );
//       },
//     );
//   }

//   // Add this new method to your _HomePageState class
//   // Replace the old _showExitDialog with this new method
//   Future<void> _showAnimatedExitDialog() async {
//     await showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//       transitionDuration: const Duration(milliseconds: 400),
//       pageBuilder: (context, animation, secondaryAnimation) {
//         // The builder now returns our new stateful dialog widget
//         return const AnimatedExitDialog();
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         // Apply the same scale and fade animation
//         return ScaleTransition(
//           scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
//           child: FadeTransition(opacity: animation, child: child),
//         );
//       },
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_vault/auth/auth_service.dart';
import 'package:link_vault/home/widgets/add_social_link_dialog.dart';
import 'package:link_vault/home/widgets/animated_exit_dialog.dart';
import 'package:link_vault/home/widgets/circular_avtar_image.dart';
import 'package:link_vault/home/widgets/info_card.dart';
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
   String qrData = "Hello, World!"; 
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

  // --- DRAWER IS NOW DYNAMIC ---
  Widget buildDrawer() {
    final authService = AuthService();

    return Container(
      width: 80,
      color: Colors.white,
      child: Column(
        children: [
          // Static Top Buttons
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            color: Colors.black,
            iconSize: 30,
            onPressed: () {
              setState(() {
                isDrawerOnRight = !isDrawerOnRight;
              });
            },
          ),
          const Divider(),
          // Dynamic Buttons from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getSocialLinksStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No links"));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return IconButton(
                      icon: Icon(_getIconForPlatform(data['iconName'])),
                      color: Colors.black,
                      iconSize: 30,
                      onPressed: () {
                        _showQrDialog(
                          context,
                          data['link'],
                          !isDrawerOnRight ? 80.0 : 0,
                          isDrawerOnRight ? 80.0 : 0,
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // Static Bottom Button
          const Divider(),
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.redAccent,
            iconSize: 30,
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
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
