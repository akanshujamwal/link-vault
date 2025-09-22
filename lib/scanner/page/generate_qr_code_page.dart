import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrCodePage extends StatefulWidget {
  const GenerateQrCodePage({super.key});

  @override
  State<GenerateQrCodePage> createState() => _GenerateQrCodePageState();
}

class _GenerateQrCodePageState extends State<GenerateQrCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: "Hello, World!", // The string you want to encode
              size: 200,
              version: QrVersions.auto,
            ),
            SizedBox(height: 20),
            Text("Scan this QR code"),
          ],
        ),
      ),
    );
  }
}
