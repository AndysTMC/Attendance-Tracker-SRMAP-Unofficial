// Create a class that is used to scan the QR Code that has IP Address, if ip address is found, go to attendance page with that ip address


import 'package:attendance_tracker/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class IPScanner extends StatefulWidget {
  const IPScanner({Key? key}) : super(key: key);

  @override
  _IPScannerState createState() => _IPScannerState();
}

class _IPScannerState extends State<IPScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  String ip = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        ip = scanData.code!;
      });
      if (ip != '') {
        controller.pauseCamera();
        Navigator.pop(context, ip);
      } else {
        Navigator.pop(context, '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text('Scan Server QR'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }
}