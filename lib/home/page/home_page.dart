import 'dart:io';
import 'dart:ui' as ui;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:link_vault/all_links/pages/all_links_page.dart';
import 'package:link_vault/home/widgets/add_or_edit_link_dialog.dart';
import 'package:link_vault/home/widgets/animated_exit_dialog.dart';
import 'package:link_vault/profile/profile_page.dart';
import 'package:link_vault/scanner/page/scanner_page.dart';
import 'package:link_vault/services/firestore_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestoreService = FirestoreService();

  // GlobalKey to identify the widget to capture
  final GlobalKey _cardKey = GlobalKey();
  // ✨ --- NEW METHODS FOR SCAN HISTORY ---

  Future<void> _showHistoryItemDialog(
    Map<dynamic, dynamic> item, {
    required bool isLocal,
    required dynamic id,
  }) async {
    final String data = item['data'] ?? 'No data';
    final Uri? uri = Uri.tryParse(data);
    final bool isUrl =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Scanned Data'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(data),
              if (isUrl)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('OPEN IN BROWSER'),
                    onPressed: () async {
                      if (uri != null) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteHistoryItem(isLocal: isLocal, id: id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHistoryItem({
    required bool isLocal,
    required dynamic id,
  }) async {
    if (isLocal) {
      final historyBox = Hive.box('scan_history');
      await historyBox.delete(id);
    } else {
      await _firestoreService.deleteScanHistory(id);
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('History item deleted.')));
  }

  Widget _buildScanHistorySection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getScanHistoryStream(),
      builder: (context, firestoreSnapshot) {
        return ValueListenableBuilder(
          valueListenable: Hive.box('scan_history').listenable(),
          builder: (context, Box localBox, _) {
            if (firestoreSnapshot.connectionState == ConnectionState.waiting &&
                localBox.values.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Combine Firestore and Local data
            final firestoreDocs = firestoreSnapshot.hasData
                ? firestoreSnapshot.data!.docs
                : [];
            final localItems = localBox.toMap().entries.toList();

            // Create a unified list
            var combinedList = [
              ...firestoreDocs.map(
                (doc) => {'isLocal': false, 'id': doc.id, 'data': doc.data()},
              ),
              ...localItems.map(
                (entry) => {
                  'isLocal': true,
                  'id': entry.key,
                  'data': Map<String, dynamic>.from(entry.value),
                },
              ),
            ];

            // Sort by timestamp descending
            combinedList.sort((a, b) {
              final dateA = DateTime.parse(a['data']['timestamp']);
              final dateB = DateTime.parse(b['data']['timestamp']);
              return dateB.compareTo(dateA);
            });

            if (combinedList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "You haven't scanned anything yet.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: combinedList.length,
              itemBuilder: (context, index) {
                final item = combinedList[index];
                final data = item['data'];
                final bool isLocal = item['isLocal'];
                final dynamic id = item['id'];

                final DateTime timestamp = DateTime.parse(data['timestamp']);
                final String formattedDate = DateFormat.yMMMd().add_jm().format(
                  timestamp,
                );
                final String scanData = data['data'] ?? 'No data';

                return Dismissible(
                  key: Key(id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    _deleteHistoryItem(isLocal: isLocal, id: id);
                  },
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white70,
                    ),
                    title: Text(
                      scanData,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    onTap: () =>
                        _showHistoryItemDialog(data, isLocal: isLocal, id: id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Function to capture and share the profile card
  Future<void> _captureAndShareCard() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint("Error: Could not find repaint boundary.");
        return;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/profile_card.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Check out my profile!');
    } catch (e) {
      debugPrint("Error capturing or sharing widget: $e");
    }
  }

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
        backgroundColor: Colors.grey[800],
        content: SizedBox(
          width: 250,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: 250.0,
                  dataModuleStyle: const QrDataModuleStyle(color: Colors.white),
                  eyeStyle: const QrEyeStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  data,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isUrl)
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.open_in_browser,
                          color: Colors.amber,
                        ),
                        label: const Text(
                          'Open',
                          style: TextStyle(color: Colors.amber),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: data));
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Opening in browser..."),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy, color: Colors.amber),
                      label: const Text(
                        'Copy',
                        style: TextStyle(color: Colors.amber),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: data));
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Copied to clipboard!")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // actions: [
        //   if (isUrl)
        //     TextButton(
        //       child: const Text("OPEN IN BROWSER"),
        //       onPressed: () async {
        //         if (uri != null) await launchUrl(uri);
        //       },
        //     ),
        //   TextButton(
        //     child: const Text("COPY"),
        //     onPressed: () {
        //       Clipboard.setData(ClipboardData(text: data));
        //       Navigator.pop(dialogContext);
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text("Copied to clipboard!")),
        //       );
        //     },
        //   ),
        // ],
      ),
    );
  }

  // ✨ --- NEW: Dialog specifically for the main profile QR code ---
  Future<void> _showMainQrDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[800],
        content: SizedBox(
          width: 250,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: "https://www.linkedin.com/in/akanshu-jamwal",
                  version: QrVersions.auto,
                  size: 250.0,
                  dataModuleStyle: const QrDataModuleStyle(color: Colors.white),
                  eyeStyle: QrEyeStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<dynamic> customLinks = List.from(userData['custom_links'] ?? []);
    customLinks.sort(
      (a, b) =>
          (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp),
    );
    final bool hasImage = (userData['photoURL'] ?? '').isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Stack(
              children: [
                RepaintBoundary(
                  key: _cardKey,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- TOP IMAGE SECTION ---
                        Container(
                          width: double.maxFinite,
                          height: screenHeight * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            image: hasImage
                                ? DecorationImage(
                                    image: NetworkImage(userData['photoURL']!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: !hasImage
                              ? const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white70,
                                )
                              : null,
                        ),
                        // --- BOTTOM DETAILS SECTION ---
                        Container(
                          width: double.maxFinite,
                          color: Colors.grey.shade900,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final availableWidth = constraints.maxWidth;
                              return Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _showMainQrDialog();
                                    },
                                    child: QrImageView(
                                      padding: EdgeInsets.zero,
                                      data:
                                          "https://www.linkedin.com/in/akanshu-jamwal", // Replace with dynamic data
                                      version: QrVersions.auto,
                                      size: availableWidth * 0.28,
                                      dataModuleStyle: const QrDataModuleStyle(
                                        color: Colors.white,
                                      ),
                                      eyeStyle: const QrEyeStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(
                                    color: Colors.white70,
                                    thickness: 1,
                                    width: screenWidth * 0.08,
                                    indent: 2,
                                    endIndent: 2,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          userData['displayName'] ?? 'No Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            // ✨ FONT SIZE CHANGE: Added clamp() for min/max font size
                                            fontSize: (screenWidth * 0.065)
                                                .clamp(20.0, 32.0),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if ((userData['designation'] ?? '')
                                            .isNotEmpty)
                                          Text(
                                            '${userData['designation']}',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              // ✨ FONT SIZE CHANGE: Added clamp() for min/max font size
                                              fontSize: (screenWidth * 0.045)
                                                  .clamp(16.0, 22.0),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 5),
                                        _buildContactRow(
                                          Icons.phone,
                                          '${userData['mobileNumber']}',
                                          screenWidth,
                                        ),
                                        const SizedBox(height: 5),
                                        _buildContactRow(
                                          Icons.email,
                                          '${userData['email']}',
                                          screenWidth,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: _captureAndShareCard,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
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
          _buildSocialGrid(customLinks),
          // ✨ --- ADD THIS NEW SECTION AT THE END ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "Scan History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildScanHistorySection(),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, double screenWidth) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          // ✨ FONT SIZE CHANGE: Clamped icon size as well for consistency
          size: (screenWidth * 0.04).clamp(16.0, 20.0),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white70,
              // ✨ FONT SIZE CHANGE: Added clamp() for min/max font size
              fontSize: (screenWidth * 0.038).clamp(14.0, 18.0),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 100,
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
                      textAlign: TextAlign.center,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          platform[0].toUpperCase() + platform.substring(1),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
