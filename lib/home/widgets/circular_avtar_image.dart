import 'package:flutter/material.dart';

class CircularImageAvatar extends StatelessWidget {
  const CircularImageAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // The total width including the border
      height: 250, // The total height including the border
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // ✅ This creates the yellow border
        border: Border.all(
          color: Colors.white,
          width: 4.0, // Adjust the border width as needed
        ),
      ),
      // ✅ ClipOval makes the image circular
      child: ClipOval(
        child: Image.asset(
          'assets/images/dp.jpeg', // Replace with your image URL
          fit: BoxFit.cover, // Ensures the image fills the circle
          width: 150, // The image width (total width - 2 * border width)
          height: 150, // The image height (total height - 2 * border width)
        ),
      ),
    );
  }
}
