import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_vault/services/firestore_service.dart';

class AddOrEditLinkDialog extends StatefulWidget {
  final Map<String, dynamic>? existingLink;

  const AddOrEditLinkDialog({super.key, this.existingLink});

  @override
  State<AddOrEditLinkDialog> createState() => _AddOrEditLinkDialogState();
}

class _AddOrEditLinkDialogState extends State<AddOrEditLinkDialog> {
  final _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _linkController;
  late TextEditingController _platformController;

  bool get _isEditing => widget.existingLink != null;

  final List<String> _platforms = [
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
    'Kaggle',
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

  @override
  void initState() {
    super.initState();
    _platformController = TextEditingController(
      text: _isEditing ? widget.existingLink!['platform'] : '',
    );
    _linkController = TextEditingController(
      text: _isEditing ? widget.existingLink!['data'] : '',
    );
  }

  @override
  void dispose() {
    _platformController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        final newLinkData = {
          'platform': _platformController.text.toLowerCase(),
          'data': _linkController.text,
          'createdAt': widget.existingLink!['createdAt'],
        };
        await _firestoreService.editLink(widget.existingLink!, newLinkData);
      } else {
        final newLinkData = {
          'platform': _platformController.text.toLowerCase(),
          'data': _linkController.text,
          'createdAt': Timestamp.now(),
        };
        await _firestoreService.addLink(newLinkData);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Link' : 'Add New Link'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isEditing)
              TextFormField(
                controller: _platformController,
                decoration: const InputDecoration(labelText: 'Platform'),
                enabled: false,
              )
            else
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _platformController.text),
                optionsBuilder: (TextEditingValue value) {
                  if (value.text.isEmpty) return const Iterable.empty();
                  return _platforms
                      .where(
                        (opt) => opt.toLowerCase().contains(
                          value.text.toLowerCase(),
                        ),
                      )
                      .take(3);
                },
                onSelected: (selection) => _platformController.text = selection,
                fieldViewBuilder:
                    (context, controller, focusNode, onSubmitted) {
                      _platformController = controller;
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Platform',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter a platform';
                          if (!_platforms.any(
                            (p) => p.toLowerCase() == value.toLowerCase(),
                          ))
                            return 'Please select a valid platform';
                          return null;
                        },
                      );
                    },
              ),
            TextFormField(
              controller: _linkController,
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(_isEditing ? 'Save Changes' : 'Save'),
        ),
      ],
    );
  }
}
