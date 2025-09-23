// Add this new widget to your file
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedExitDialog extends StatefulWidget {
  const AnimatedExitDialog({super.key});

  @override
  State<AnimatedExitDialog> createState() => _AnimatedExitDialogState();
}

class _AnimatedExitDialogState extends State<AnimatedExitDialog> {
  bool _isExiting = false;

  void _triggerExit() {
    setState(() {
      _isExiting = true;
    });

    // Wait for the animation to be seen, then close the app
    Future.delayed(const Duration(seconds: 2), () {
      SystemNavigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isExiting ? "Closing App" : "Exit App"),
      content: _isExiting
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("See you soon! 👋"),
              ],
            )
          : const Text('Are you sure you want to close?'),
      actions: _isExiting
          ? null // No buttons when showing the exit message
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // User says No
                child: const Text('No'),
              ),
              TextButton(
                onPressed: _triggerExit, // User says Yes
                child: const Text('Yes'),
              ),
            ],
    );
  }
}
