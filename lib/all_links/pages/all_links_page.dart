import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/home/widgets/add_or_edit_link_dialog.dart';
import 'package:link_vault/services/firestore_service.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class AllLinksPage extends StatefulWidget {
  const AllLinksPage({super.key});

  @override
  State<AllLinksPage> createState() => _AllLinksPageState();
}

class _AllLinksPageState extends State<AllLinksPage> {
  final _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _selectedLinks = [];
  bool _isSelectionMode = false;
  bool _isArrangeMode = false;

  void _toggleSelection(Map<String, dynamic> link) {
    setState(() {
      // Using a unique identifier like the timestamp to compare maps
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

  void _exitAllModes() {
    setState(() {
      _isSelectionMode = false;
      _isArrangeMode = false;
      _selectedLinks.clear();
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
              onPressed: () {
                showDialog(
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
              await _firestoreService.deleteMultipleLinks(_selectedLinks);
              _exitAllModes();
            },
          ),
        ],
      );
    }

    if (_isArrangeMode) {
      return AppBar(
        backgroundColor: Colors.black,
        title: const Text('Arrange Links'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Done',
            onPressed: _exitAllModes,
          ),
        ],
      );
    }

    return AppBar(
      title: const Text('All My Links'),
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(Icons.reorder),
          tooltip: 'Arrange',
          onPressed: () => setState(() => _isArrangeMode = true),
        ),
      ],
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
        body: StreamBuilder<DocumentSnapshot>(
          stream: _firestoreService.getUserStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final List<dynamic> allLinksDyn =
                (snapshot.data!.data()
                    as Map<String, dynamic>)['custom_links'] ??
                [];
            final List<Map<String, dynamic>> allLinks = allLinksDyn
                .cast<Map<String, dynamic>>();

            return ReorderableGridView.builder(
              padding: const EdgeInsets.all(16),
              dragEnabled: _isArrangeMode,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final item = allLinks.removeAt(oldIndex);
                  allLinks.insert(newIndex, item);
                });
                _firestoreService.updateLinksOrder(allLinks);
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: allLinks.length,
              itemBuilder: (context, index) {
                final item = allLinks[index];
                final isSelected = _selectedLinks.any(
                  (element) => element['createdAt'] == item['createdAt'],
                );

                // ✨ --- FIX: Removed the incorrect 'buildDraggable' wrapper ---
                return InkWell(
                  key: ValueKey(
                    item['createdAt'],
                  ), // A unique key is important for reordering
                  onTap: () {
                    if (_isSelectionMode) _toggleSelection(item);
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
                      border: isSelected
                          ? Border.all(color: Colors.blueAccent, width: 2)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIconForPlatform(item['platform']),
                              color: Colors.white,
                              size: 35,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (item['platform'] as String).capitalize(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        if (isSelected)
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
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
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

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
