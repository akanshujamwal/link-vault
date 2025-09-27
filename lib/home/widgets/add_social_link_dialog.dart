import 'package:flutter/material.dart';
import 'package:link_vault/services/firestore_service.dart';

class AddSocialLinkDialog extends StatefulWidget {
  const AddSocialLinkDialog({super.key});

  @override
  _AddSocialLinkDialogState createState() => _AddSocialLinkDialogState();
}

class _AddSocialLinkDialogState extends State<AddSocialLinkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _linkController = TextEditingController();
  final _customPlatformController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  String _selectedPlatform = 'LinkedIn';
  bool _showCustomPlatformField = false;

  // Pre-defined platforms and their corresponding icon names (we'll map these later)
  final Map<String, String> _platformIcons = {
    'LinkedIn': 'linkedin',
    'GitHub': 'github',
    'Twitter': 'twitter',
    'Website': 'language',
    'Other': 'add_circle',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Link'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPlatform,
                items: _platformIcons.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPlatform = newValue!;
                    _showCustomPlatformField = newValue == 'Other';
                  });
                },
                decoration: const InputDecoration(labelText: 'Platform'),
              ),
              if (_showCustomPlatformField)
                TextFormField(
                  controller: _customPlatformController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Platform Name',
                  ),
                  validator: (value) {
                    if (_showCustomPlatformField &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter a platform name';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(labelText: 'Link or Text'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a link or text';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveLink, child: const Text('Save')),
      ],
    );
  }

  void _saveLink() {
    if (_formKey.currentState!.validate()) {
      String platformName = _showCustomPlatformField
          ? _customPlatformController.text
          : _selectedPlatform;
      String iconName = _platformIcons[_selectedPlatform] ?? 'add_circle';

      _firestoreService.addSocialLink(
        platform: platformName,
        link: _linkController.text,
        iconName: iconName,
      );

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    _customPlatformController.dispose();
    super.dispose();
  }
}
