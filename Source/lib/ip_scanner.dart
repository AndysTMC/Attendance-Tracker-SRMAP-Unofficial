// Create a class that is used to scan the QR Code that has IP Address, if ip address is found, go to attendance page with that ip address


import 'package:attendance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class IPScanner extends StatefulWidget {
  const IPScanner({Key? key}) : super(key: key);

  @override
  _IPScannerState createState() => _IPScannerState();
}

class _IPScannerState extends State<IPScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  String ip_addrs = '';

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make the status bar transparent or set a different color
      statusBarIconBrightness: Brightness.dark, // Use light icons on the status bar
    ));
    controller.dispose();
    super.dispose();
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        ip_addrs = scanData.code!;
      });
      HapticFeedback.heavyImpact();
      controller.pauseCamera();
      List<String> ipList = ip_addrs.split(',');
      String result = '';
      for(int i = 0; i < ipList.length; ++i) {
        Uri url = Uri.parse('http://${ipList[i]}:8000/checking/');
        try {
          final response = await http.post(url, body: {}).timeout(const Duration(milliseconds: 500));
          if(response.statusCode == 200) {
            result = ipList[i];
            break;
          }
        } on Exception catch (e) {
          continue;
        }
      }
      navigatorKey.currentState!.pop(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Make the status bar transparent or set a different color
        statusBarIconBrightness: Brightness.dark, // Use light icons on the status bar
      ));
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text('Scan Server QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
        iconTheme: const IconThemeData(color: Colors.white),
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