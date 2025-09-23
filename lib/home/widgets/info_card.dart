import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for clipboard services

class ContactInfoCard extends StatelessWidget {
  final String phoneNumber = '+91 98765 43210';
  final String email = 'hello@flutterdev.com';

  const ContactInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column takes minimum vertical space
          children: [
            // Phone Number Row
            _CopyableInfoRow(icon: Icons.phone, text: phoneNumber),
            const Divider(height: 1), // Visual separator
            // Email Row
            _CopyableInfoRow(icon: Icons.email, text: email),
          ],
        ),
      ),
    );
  }
}

// This is the reusable widget for each row
class _CopyableInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CopyableInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(), // This pushes the copy button to the end
          IconButton(
            icon: const Icon(Icons.copy, size: 20.0),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text)).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"$text" copied to clipboard!')),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
