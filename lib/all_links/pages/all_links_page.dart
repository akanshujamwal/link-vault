
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/home/widgets/add_or_edit_link_dialog.dart';
import 'package:link_vault/services/firestore_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AllLinksPage extends StatefulWidget {
  const AllLinksPage({super.key});

  @override
  State<AllLinksPage> createState() => _AllLinksPageState();
}

class _AllLinksPageState extends State<AllLinksPage> {
  final _firestoreService = FirestoreService();

  // State for the main list of links, controlled by a StreamSubscription
  List<Map<String, dynamic>> _links = [];
  StreamSubscription<DocumentSnapshot>? _linksSubscription;
  bool _isLoading = true;

  // State for multi-selection mode (for deleting/editing)
  List<Map<String, dynamic>> _selectedLinks = [];
  bool _isSelectionMode = false;

  // State for the new tap-to-arrange mode
  List<Map<String, dynamic>> _numberedSelection = [];
  bool _isArrangeMode = false;

  @override
  void initState() {
    super.initState();
    _subscribeToLinks();
  }

  void _subscribeToLinks() {
    _linksSubscription = _firestoreService.getUserStream().listen((snapshot) {
      if (mounted) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final List<dynamic> linksFromDb = data['custom_links'] ?? [];
          setState(() {
            _links = linksFromDb.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _links = [];
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _linksSubscription?.cancel();
    super.dispose();
  }

  Future<void> _showQrDialog(Map<String, dynamic> linkItem) async {
    final String data = linkItem['data'] as String? ?? '';
    if (data.isEmpty) return;

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
                SelectableText(
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

  void _toggleSelection(Map<String, dynamic> link) {
    setState(() {
      final linkExists = _selectedLinks.any(
        (element) => element['createdAt'] == link['createdAt'],
      );
      if (linkExists) {
        _selectedLinks.removeWhere(
          (element) => element['createdAt'] == link['createdAt'],
        );
      } else {
        _selectedLinks.add(link);
      }
      if (_selectedLinks.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _onArrangeItemTap(Map<String, dynamic> link) {
    setState(() {
      final isAlreadySelected = _numberedSelection.any(
        (element) => element['createdAt'] == link['createdAt'],
      );
      if (!isAlreadySelected) {
        _numberedSelection.add(link);
      }
    });
  }

  void _finalizeArrangement() {
    final unselectedLinks = _links.where((link) {
      return !_numberedSelection.any(
        (selected) => selected['createdAt'] == link['createdAt'],
      );
    }).toList();
    final finalList = [..._numberedSelection, ...unselectedLinks];
    _firestoreService.updateLinksOrder(finalList);
    _exitAllModes();
  }

  void _exitAllModes() {
    setState(() {
      _isSelectionMode = false;
      _isArrangeMode = false;
      _selectedLinks.clear();
      _numberedSelection.clear();
    });
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

  AppBar _buildAppBar(BuildContext context) {
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitAllModes,
        ),
        title: Text('${_selectedLinks.length} selected'),
        actions: [
          if (_selectedLinks.length == 1)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) =>
                      AddOrEditLinkDialog(existingLink: _selectedLinks.first),
                );
                _exitAllModes();
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Links?'),
                  content: Text(
                    'Are you sure you want to delete ${_selectedLinks.length} selected link(s)?',
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
                await _firestoreService.deleteMultipleLinks(_selectedLinks);
                _exitAllModes();
              }
            },
          ),
        ],
      );
    }

    if (_isArrangeMode) {
      return AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: _exitAllModes,
        ),
        title: const Text('Tap in New Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Reset Selection',
            onPressed: () => setState(() => _numberedSelection.clear()),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Done',
            onPressed: _finalizeArrangement,
          ),
        ],
      );
    }

    return AppBar(
      title: const Text('All My Links'),
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: 'Arrange by Tapping',
          onPressed: () => setState(() => _isArrangeMode = true),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_links.isEmpty) {
      return const Center(
        child: Text(
          "You haven't added any links yet.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _links.length,
      itemBuilder: (context, index) {
        final item = _links[index];
        final isSelectedForDelete = _selectedLinks.any(
          (e) => e['createdAt'] == item['createdAt'],
        );

        final arrangeIndex = _numberedSelection.indexWhere(
          (e) => e['createdAt'] == item['createdAt'],
        );
        final arrangeNumber = arrangeIndex != -1 ? arrangeIndex + 1 : null;

        final String platform = item['platform'] as String;
        final String displayName = (platform.toLowerCase() == 'other')
            ? (item['customPlatformName'] as String? ?? 'Other').capitalize()
            : platform.capitalize();

        return InkWell(
          key: ValueKey(item['createdAt']),
          onTap: () {
            if (_isArrangeMode) {
              _onArrangeItemTap(item);
            } else if (_isSelectionMode) {
              _toggleSelection(item);
            } else {
              _showQrDialog(item);
            }
          },
          onLongPress: () {
            if (!_isArrangeMode) {
              setState(() {
                _isSelectionMode = true;
                _toggleSelection(item);
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: isSelectedForDelete
                  ? Border.all(color: Colors.blueAccent, width: 2.5)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForPlatform(platform),
                      color: Colors.white,
                      size: 35,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        displayName,
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
                if (isSelectedForDelete)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.blueAccent,
                    ),
                  ),
                if (_isArrangeMode && arrangeNumber != null)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '$arrangeNumber',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSelectionMode && !_isArrangeMode,
      onPopInvoked: (didPop) {
        if (!didPop) _exitAllModes();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(context),
        body: _buildBody(),
        floatingActionButton: (_isSelectionMode || _isArrangeMode)
            ? null
            : FloatingActionButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const AddOrEditLinkDialog(),
                ),
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black),
              ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
