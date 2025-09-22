import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller!.scannedDataStream.listen((scanData) {
      controller!.dispose(); // Stop scanning
      Navigator.of(context).pop(scanData.code); // Return scanned code
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
