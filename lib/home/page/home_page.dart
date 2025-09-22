import 'package:flutter/material.dart';
import 'package:link_vault/scanner/page/scanner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String qrData = "Hello, World!"; // Initial value

  // Function to scan QR code
  Future<void> scanQrCode() async {
    try {
      // Navigate to QR Scanner page and get the scanned result
      final scannedData = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const QRScannerPage()),
      );

      if (scannedData != null) {
        setState(() {
          qrData = scannedData;
        });
      }
    } catch (e) {
      setState(() {
        qrData = 'Error scanning QR: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: scanQrCode,
        child: const Icon(Icons.qr_code_scanner, size: 50),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/generate');
              },
              child: const Text("Generate QR code"),
            ),
            const SizedBox(height: 20),
            Text('Scanned QR: $qrData'),
          ],
        ),
      ),
    );
  }
}
