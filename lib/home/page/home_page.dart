// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:link_vault/all_links/pages/all_links_page.dart';
// import 'package:link_vault/home/widgets/add_or_edit_link_dialog.dart';
// import 'package:link_vault/home/widgets/animated_exit_dialog.dart';
// import 'package:link_vault/profile/profile_page.dart';
// import 'package:link_vault/scanner/page/scanner_page.dart';
// import 'package:link_vault/services/firestore_service.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final _firestoreService = FirestoreService();

//   void _onItemTapped(int index) {
//     if (index == 1) {
//       Navigator.of(
//         context,
//       ).push(MaterialPageRoute(builder: (context) => const QRScannerPage()));
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const ProfilePage()),
//       );
//     }
//   }

//   IconData _getIconForPlatform(String platform) {
//     switch (platform.toLowerCase()) {
//       case 'linkedin':
//         return Icons.business_center;
//       case 'github':
//         return Icons.code;
//       case 'twitter':
//         return Icons.message;
//       case 'facebook':
//         return Icons.facebook;
//       case 'instagram':
//         return Icons.camera_alt;
//       case 'discord':
//         return Icons.chat;
//       case 'dev.to':
//         return Icons.article;
//       case 'hashnode':
//         return Icons.notes;
//       case 'medium':
//         return Icons.article_outlined;
//       case 'youtube':
//         return Icons.play_circle_filled;
//       case 'rssfeed':
//         return Icons.rss_feed;
//       case 'codepen':
//         return Icons.edit;
//       case 'codesandbox':
//         return Icons.widgets;
//       case 'dribbble':
//         return Icons.sports_basketball;
//       case 'behance':
//         return Icons.palette;
//       case 'stackoverflow':
//         return Icons.question_answer;
//       case 'kaggle':
//         return Icons.analytics;
//       case 'codechef':
//         return Icons.emoji_events;
//       case 'hackerrank':
//         return Icons.star;
//       case 'codeforces':
//         return Icons.military_tech;
//       case 'leetcode':
//         return Icons.keyboard;
//       case 'topcoder':
//         return Icons.leaderboard;
//       case 'hackerearth':
//         return Icons.public;
//       case 'geeksforgeeks':
//         return Icons.school;
//       case 'website':
//         return Icons.language;
//       default:
//         return Icons.link;
//     }
//   }

//   Future<void> _showQrDialog(BuildContext context, String data) async {
//     final Uri? uri = Uri.tryParse(data);
//     final bool isUrl =
//         uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

//     await showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         backgroundColor: Colors.white,
//         content: SizedBox(
//           width: 250,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 QrImageView(
//                   data: data,
//                   version: QrVersions.auto,
//                   size: 200.0,
//                   dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
//                   eyeStyle: const QrEyeStyle(color: Colors.black),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   data,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.black),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           if (isUrl)
//             TextButton(
//               child: const Text("OPEN IN BROWSER"),
//               onPressed: () async {
//                 if (uri != null) await launchUrl(uri);
//               },
//             ),
//           TextButton(
//             child: const Text("COPY"),
//             onPressed: () {
//               Clipboard.setData(ClipboardData(text: data));
//               Navigator.pop(dialogContext);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Copied to clipboard!")),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLinkOptionsDialog(Map<String, dynamic> linkData) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           color: const Color(0xFF1E1E1E),
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.qr_code, color: Colors.white),
//                 title: const Text(
//                   'Show QR Code',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showQrDialog(context, linkData['data']);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.edit, color: Colors.white),
//                 title: const Text(
//                   'Edit Link',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   showDialog(
//                     context: context,
//                     builder: (_) => AddOrEditLinkDialog(existingLink: linkData),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.delete, color: Colors.redAccent),
//                 title: const Text(
//                   'Delete Link',
//                   style: TextStyle(color: Colors.redAccent),
//                 ),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final bool? confirm = await showDialog<bool>(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Delete Link?'),
//                       content: Text(
//                         'Are you sure you want to delete your ${linkData['platform']} link?',
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, false),
//                           child: const Text('Cancel'),
//                         ),
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, true),
//                           child: const Text(
//                             'Delete',
//                             style: TextStyle(color: Colors.redAccent),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                   if (confirm == true) {
//                     await _firestoreService.deleteLink(linkData);
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           showDialog(
//             context: context,
//             builder: (_) => const AnimatedExitDialog(),
//           );
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SafeArea(
//           child: StreamBuilder<DocumentSnapshot>(
//             stream: _firestoreService.getUserStream(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (!snapshot.hasData || !snapshot.data!.exists) {
//                 return const Center(
//                   child: Text(
//                     "Could not load profile.",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 );
//               }
//               final userData = snapshot.data!.data() as Map<String, dynamic>;
//               return _buildHomeBody(userData);
//             },
//           ),
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.qr_code_scanner),
//               label: 'Scan',
//             ),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//           ],
//           currentIndex: 0,
//           onTap: _onItemTapped,
//         ),
//       ),
//     );
//   }

//   Widget _buildHomeBody(Map<String, dynamic> userData) {
//     final List<dynamic> customLinks = List.from(userData['custom_links'] ?? []);
//     customLinks.sort(
//       (a, b) =>
//           (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp),
//     );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 50),
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.4,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Spacer(),
//                 CircleAvatar(
//                   radius: 80,
//                   backgroundImage: (userData['photoURL'] ?? '').isNotEmpty
//                       ? NetworkImage(userData['photoURL'])
//                       : null,
//                   child: (userData['photoURL'] ?? '').isEmpty
//                       ? const Icon(Icons.person, size: 60)
//                       : null,
//                 ),
//                 const SizedBox(height: 20),
//                 Card(
//                   elevation: 8.0,
//                   margin: const EdgeInsets.all(16.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                   ),
//                   color: Colors.grey.shade800,
//                   child: IntrinsicHeight(
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Row(
//                         mainAxisSize:
//                             MainAxisSize.min, // Shrink-wrap the content
//                         children: [
//                           Container(
//                             width: 90,
//                             height: 90,
//                             color: Colors.red.shade300,
//                           ),

//                           // Making the divider impossible to miss
//                           const VerticalDivider(
//                             color: Colors.white70,
//                             thickness: 1,
//                             width: 40,
//                             indent: 2,
//                             endIndent: 2,
//                           ),

//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 userData['displayName'] ?? 'No Name',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   fontSize: 28,
//                                 ),
//                               ),

//                               if ((userData['designation'] ?? '').isNotEmpty)
//                                 Text(
//                                   '${userData['designation']}',
//                                   style: const TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 24,
//                                   ),
//                                 ),
//                               const SizedBox(height: 5),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.phone,
//                                     color: Colors.white70,
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 5),
//                                   Text(
//                                     '${userData['mobileNumber']}',
//                                     style: const TextStyle(
//                                       color: Colors.white70,
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 5),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.email,
//                                     color: Colors.white70,
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 5),
//                                   Text(
//                                     '${userData['email']}',
//                                     style: const TextStyle(
//                                       color: Colors.white70,
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 const Spacer(),
//               ],
//             ),
//           ),
//         ),
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Text(
//             "My Links",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         Expanded(child: _buildSocialGrid(customLinks)),
//       ],
//     );
//   }

//   Widget _buildSocialGrid(List<dynamic> links) {
//     final platformCounts = <String, int>{};
//     for (var link in links) {
//       final platform = link['platform'] as String;
//       platformCounts[platform] = (platformCounts[platform] ?? 0) + 1;
//     }
//     final duplicatePlatforms = platformCounts.entries
//         .where((entry) => entry.value > 1)
//         .map((entry) => entry.key)
//         .toSet();

//     List<dynamic> gridItems = [];
//     bool hasMore = links.length > 5;

//     if (hasMore) {
//       gridItems = links.take(5).toList();
//       gridItems.add({'platform': 'show_more'});
//     } else {
//       gridItems = List.from(links);
//       gridItems.add({'platform': 'add_new'});
//     }

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       child: GridView.builder(
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         itemCount: gridItems.length,
//         itemBuilder: (context, index) {
//           final item = gridItems[index];
//           final String platform = item['platform'];

//           // ✨ --- FIX: The onTap logic for these two buttons is now restored ---
//           if (platform == 'add_new' || platform == 'show_more') {
//             return InkWell(
//               onTap: () {
//                 if (platform == 'add_new') {
//                   showDialog(
//                     context: context,
//                     builder: (_) => const AddOrEditLinkDialog(),
//                   );
//                 } else {
//                   // platform == 'show_more'
//                   Navigator.push(
//                     context,
//                     // ✨ --- The AllLinksPage constructor is now empty ---
//                     MaterialPageRoute(
//                       builder: (context) => const AllLinksPage(),
//                     ),
//                   );
//                 }
//               },
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade800,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       platform == 'add_new' ? Icons.add : Icons.more_horiz,
//                       color: Colors.white,
//                       size: 35,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       platform == 'add_new' ? "Add New" : "Show More",
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final IconData icon = _getIconForPlatform(platform);
//           final bool isDuplicate = duplicatePlatforms.contains(platform);

//           return Stack(
//             children: [
//               InkWell(
//                 onTap: () => _showQrDialog(context, item['data']),
//                 onLongPress: () => _showLinkOptionsDialog(item),
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   width: double.infinity,
//                   height: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade900,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(icon, color: Colors.white, size: 35),
//                       const SizedBox(height: 8),
//                       Text(
//                         platform[0].toUpperCase() + platform.substring(1),
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 12,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (isDuplicate)
//                 Positioned(
//                   top: 4,
//                   left: 4,
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: const BoxDecoration(
//                       color: Colors.black54,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.control_point_duplicate,
//                       color: Colors.amber,
//                       size: 16,
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/all_links/pages/all_links_page.dart';
import 'package:link_vault/home/widgets/add_or_edit_link_dialog.dart';
import 'package:link_vault/home/widgets/animated_exit_dialog.dart';
import 'package:link_vault/profile/profile_page.dart';
import 'package:link_vault/scanner/page/scanner_page.dart';
import 'package:link_vault/services/firestore_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestoreService = FirestoreService();

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const QRScannerPage()));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
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
                  showDialog(
                    context: context,
                    builder: (_) => AddOrEditLinkDialog(existingLink: linkData),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text(
                  'Delete Link',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  Navigator.pop(context);
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
                  if (confirm == true) {
                    await _firestoreService.deleteLink(linkData);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          showDialog(
            context: context,
            builder: (_) => const AnimatedExitDialog(),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _firestoreService.getUserStream(),
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

  Widget _buildHomeBody(Map<String, dynamic> userData) {
    final List<dynamic> customLinks = List.from(userData['custom_links'] ?? []);
    customLinks.sort(
      (a, b) =>
          (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp),
    );
    final bool hasImage = (userData['photoURL'] ?? '').isNotEmpty;
    // ✨ --- WRAPPED THE COLUMN WITH SingleChildScrollView ---
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              // Set a background color for the fallback icon case
              color: Colors.grey.shade800,
              // The border radius you requested
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            // Removed fixed height to allow for flexible content
            // height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double
                          .maxFinite, // Diameter of the old CircleAvatar (radius: 80)
                      height:
                          400, // Diameter of the old CircleAvatar (radius: 80)
                      decoration: BoxDecoration(
                        // Set a background color for the fallback icon case
                        color: Colors.grey[800],

                        // The border radius you requested
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),

                        // Conditionally apply the background image
                        image: hasImage
                            ? DecorationImage(
                                image: NetworkImage(userData['photoURL']!),
                                // This makes the image cover the container without distortion
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      // Conditionally show the icon if there's no image
                      child: !hasImage
                          ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white70,
                            )
                          : null,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double
                          .maxFinite, // Diameter of the old CircleAvatar (radius: 80)
                      height:
                          160, // Diameter of the old CircleAvatar (radius: 80)
                      decoration: BoxDecoration(
                        // Set a background color for the fallback icon case
                        color: Colors.black,

                        // The border radius you requested
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),

                        // Conditionally apply the background image
                      ),
                      // Conditionally show the icon if there's no image
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              color: Colors.red.shade300,
                            ),
                            const VerticalDivider(
                              color: Colors.white70,
                              thickness: 1,
                              width: 40,
                              indent: 2,
                              endIndent: 2,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData['displayName'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 28,
                                  ),
                                ),
                                if ((userData['designation'] ?? '').isNotEmpty)
                                  Text(
                                    '${userData['designation']}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 24,
                                    ),
                                  ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${userData['mobileNumber']}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${userData['email']}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Card(
                  //   elevation: 0,
                  //   // margin: const EdgeInsets.all(16.0),
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.only(
                  //       bottomLeft: Radius.circular(12),
                  //       bottomRight: Radius.circular(12),
                  //     ),
                  //   ),
                  //   color: Colors.black,
                  //   child: IntrinsicHeight(
                  //     child: Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Container(
                  //             width: 90,
                  //             height: 90,
                  //             color: Colors.red.shade300,
                  //           ),
                  //           const VerticalDivider(
                  //             color: Colors.white70,
                  //             thickness: 1,
                  //             width: 40,
                  //             indent: 2,
                  //             endIndent: 2,
                  //           ),
                  //           Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(
                  //                 userData['displayName'] ?? 'No Name',
                  //                 style: const TextStyle(
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Colors.white,
                  //                   fontSize: 28,
                  //                 ),
                  //               ),
                  //               if ((userData['designation'] ?? '').isNotEmpty)
                  //                 Text(
                  //                   '${userData['designation']}',
                  //                   style: const TextStyle(
                  //                     color: Colors.white70,
                  //                     fontSize: 24,
                  //                   ),
                  //                 ),
                  //               const SizedBox(height: 5),
                  //               Row(
                  //                 children: [
                  //                   const Icon(
                  //                     Icons.phone,
                  //                     color: Colors.white70,
                  //                     size: 18,
                  //                   ),
                  //                   const SizedBox(width: 5),
                  //                   Text(
                  //                     '${userData['mobileNumber']}',
                  //                     style: const TextStyle(
                  //                       color: Colors.white70,
                  //                       fontSize: 18,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //               const SizedBox(height: 5),
                  //               Row(
                  //                 children: [
                  //                   const Icon(
                  //                     Icons.email,
                  //                     color: Colors.white70,
                  //                     size: 18,
                  //                   ),
                  //                   const SizedBox(width: 5),
                  //                   Text(
                  //                     '${userData['email']}',
                  //                     style: const TextStyle(
                  //                       color: Colors.white70,
                  //                       fontSize: 18,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ],
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
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
          const SizedBox(height: 15),
          // ✨ --- REMOVED THE Expanded WIDGET ---
          _buildSocialGrid(customLinks),
        ],
      ),
    );
  }

  Widget _buildSocialGrid(List<dynamic> links) {
    final platformCounts = <String, int>{};
    for (var link in links) {
      final platform = link['platform'] as String;
      platformCounts[platform] = (platformCounts[platform] ?? 0) + 1;
    }
    final duplicatePlatforms = platformCounts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toSet();

    List<dynamic> gridItems = [];
    bool hasMore = links.length > 7;

    if (hasMore) {
      gridItems = links.take(7).toList();
      gridItems.add({'platform': 'show_more'});
    } else {
      gridItems = List.from(links);
      gridItems.add({'platform': 'add_new'});
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        // ✨ --- ADDED shrinkWrap TO PREVENT LAYOUT ERRORS ---
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: gridItems.length,
        itemBuilder: (context, index) {
          final item = gridItems[index];
          final String platform = item['platform'];

          if (platform == 'add_new' || platform == 'show_more') {
            return InkWell(
              onTap: () {
                if (platform == 'add_new') {
                  showDialog(
                    context: context,
                    builder: (_) => const AddOrEditLinkDialog(),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllLinksPage(),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      platform == 'add_new' ? Icons.add : Icons.more_horiz,
                      color: Colors.white,
                      size: 35,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      platform == 'add_new' ? "Add New" : "Show More",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final IconData icon = _getIconForPlatform(platform);
          final bool isDuplicate = duplicatePlatforms.contains(platform);

          return Stack(
            children: [
              InkWell(
                onTap: () => _showQrDialog(context, item['data']),
                onLongPress: () => _showLinkOptionsDialog(item),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
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
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              if (isDuplicate)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.control_point_duplicate,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
