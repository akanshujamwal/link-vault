
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:link_vault/services/firestore_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart'; // ✨ 1. IMPORT GEOCODING

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final FirestoreService _firestoreService = FirestoreService();
  QRViewController? controller;

  Timer? _inactivityTimer;
  bool _isScanning = true;
  String _randomQrData = '';

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 1), _onTimeout);
  }

  void _onTimeout() {
    if (mounted) {
      setState(() {
        _isScanning = false;
        _randomQrData = 'Generated at: ${DateTime.now().toIso8601String()}';
        controller?.stopCamera();
      });
    }
  }

  void _restartScanner() {
    setState(() {
      _isScanning = true;
    });
    controller?.resumeCamera();
    _startInactivityTimer();
  }

  Future<void> _handleScan(Barcode scanData) async {
    if (!_isScanning) return;
    _inactivityTimer?.cancel();

    setState(() {
      _isScanning = false;
    });
    await controller?.pauseCamera();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Processing scan...')));

    try {
      Position? position = await _determinePosition();
      final scanRecord = {
        'data': scanData.code,
        'timestamp': DateTime.now().toIso8601String(),
        'latitude': position?.latitude,
        'longitude': position?.longitude,
      };

      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        await _firestoreService.addScanHistory(scanRecord);
      } else {
        final historyBox = Hive.box('scan_history');
        await historyBox.add(scanRecord);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Scan saved to history!')));
        _onTimeout();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error processing scan: $e')));
        _restartScanner();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          if (_isScanning) _buildScannerView() else _buildTimeoutView(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Scans",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(child: _buildScanHistorySection()),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    // This widget remains unchanged
    return Column(
      children: [
        const Text(
          'Point your camera at a QR code',
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          width: 250,
          height: 250,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Theme.of(context).primaryColor,
              borderRadius: 15,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 245,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeoutView() {
    // This widget remains unchanged, but I've wrapped it in a Column
    // for better layout consistency.
    return Column(
      children: [
        const Text(
          'Scanner is paused. Tap below to reactivate.',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: QrImageView(
            data: _randomQrData,
            version: QrVersions.auto,
            size: 226,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Tap to Scan Again'),
          onPressed: _restartScanner,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController ctrl) {
    setState(() {
      controller = ctrl;
    });
    controller!.scannedDataStream.listen((scanData) {
      _handleScan(scanData);
    });
  }

  Widget _buildScanHistorySection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getScanHistoryStream(),
      builder: (context, firestoreSnapshot) {
        return ValueListenableBuilder(
          valueListenable: Hive.box('scan_history').listenable(),
          builder: (context, Box localBox, _) {
            if (firestoreSnapshot.connectionState == ConnectionState.waiting &&
                localBox.values.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final firestoreDocs = firestoreSnapshot.hasData
                ? firestoreSnapshot.data!.docs
                : [];
            final localItems = localBox.toMap().entries.toList();

            var combinedList = [
              ...firestoreDocs.map(
                (doc) => {'isLocal': false, 'id': doc.id, 'data': doc.data()},
              ),
              ...localItems.map(
                (entry) => {
                  'isLocal': true,
                  'id': entry.key,
                  'data': Map<String, dynamic>.from(entry.value),
                },
              ),
            ];

            combinedList.sort((a, b) {
              final dateA = DateTime.parse(a['data']['timestamp']);
              final dateB = DateTime.parse(b['data']['timestamp']);
              return dateB.compareTo(dateA);
            });

            if (combinedList.isEmpty) {
              return const Center(
                child: Text(
                  "You haven't scanned anything yet.",
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return ListView.builder(
              itemCount: combinedList.length,
              itemBuilder: (context, index) {
                final item = combinedList[index];
                final data = item['data'];
                final bool isLocal = item['isLocal'];
                final dynamic id = item['id'];

                final DateTime timestamp = DateTime.parse(data['timestamp']);
                final String formattedDate = DateFormat.yMMMd().add_jm().format(
                  timestamp,
                );
                final String scanData = data['data'] ?? 'No data';

                // ✨ 2. EXTRACT LATITUDE AND LONGITUDE
                final double? latitude = data['latitude'] as double?;
                final double? longitude = data['longitude'] as double?;

                return Dismissible(
                  key: Key(id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    _deleteHistoryItem(isLocal: isLocal, id: id);
                  },
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.qr_code, color: Colors.white70),
                    title: Text(
                      scanData,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                    // ✨ 3. UPDATE THE SUBTITLE TO SHOW LOCATION AND DATE
                    isThreeLine: true,
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        PlacemarkWidget(
                          latitude: latitude,
                          longitude: longitude,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    onTap: () =>
                        _showHistoryItemDialog(data, isLocal: isLocal, id: id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showHistoryItemDialog(
    Map<dynamic, dynamic> item, {
    required bool isLocal,
    required dynamic id,
  }) async {
    // This method already contains the correct logic and remains unchanged.
    final String data = item['data'] ?? 'No data';
    final Uri? uri = Uri.tryParse(data);
    final bool isUrl =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Scanned Data'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              SelectableText(data),
              if (isUrl)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('OPEN IN BROWSER'),
                    onPressed: () async {
                      if (uri != null) {
                        // Added canLaunchUrl check for robustness
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('CLOSE'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteHistoryItem(isLocal: isLocal, id: id);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHistoryItem({
    required bool isLocal,
    required dynamic id,
  }) async {
    // This method remains unchanged
    if (isLocal) {
      final historyBox = Hive.box('scan_history');
      await historyBox.delete(id);
    } else {
      await _firestoreService.deleteScanHistory(id);
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('History item deleted.')));
    }
  }

  Future<Position?> _determinePosition() async {
    // This method remains unchanged
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    controller?.dispose();
    super.dispose();
  }
}

// ✨ 4. NEW WIDGET TO HANDLE GEOCODING FOR EACH TILE
// This widget fetches the human-readable address from coordinates.
// It's a StatefulWidget so it can manage its own loading state.
class PlacemarkWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const PlacemarkWidget({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<PlacemarkWidget> createState() => _PlacemarkWidgetState();
}

class _PlacemarkWidgetState extends State<PlacemarkWidget> {
  String _placemarkString = '...'; // Initial loading state

  @override
  void initState() {
    super.initState();
    _getPlacemark();
  }

  Future<void> _getPlacemark() async {
    if (widget.latitude == null || widget.longitude == null) {
      if (mounted) {
        setState(() {
          _placemarkString = 'Location not available';
        });
      }
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.latitude!,
        widget.longitude!,
      );

      if (placemarks.isNotEmpty && mounted) {
        final Placemark place = placemarks.first;
        // Build a readable address, filtering out empty parts
        final addressParts = [
          place.subLocality, // e.g., Saki Naka
          place.locality, // e.g., Mumbai
        ].where((part) => part != null && part.isNotEmpty).toList();

        setState(() {
          _placemarkString = addressParts.isEmpty
              ? 'Unknown Location'
              : addressParts.join(', ');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _placemarkString = 'Could not determine location';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _placemarkString,
      style: const TextStyle(color: Colors.white60, fontSize: 13),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
