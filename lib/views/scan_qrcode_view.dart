import 'dart:developer';
import 'dart:io';

import 'package:analysis_app/constants/colors.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sqflite/sqflite.dart';

import '../models/database_manager.dart';

class ScanQRView extends StatefulWidget {
  const ScanQRView({super.key});

  @override
  State<ScanQRView> createState() => _ScanQRViewState();
}

class _ScanQRViewState extends State<ScanQRView> {
  Barcode? result;
  QRViewController? _controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    _controller?.resumeCamera();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller!.pauseCamera();
    }
    _controller!.resumeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 5,
                child: _buildQrView(context),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.flash_on,
                      color: AppColors.eggshellColor,
                    ),
                    onPressed: () async {
                      await _controller?.toggleFlash();
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.flip_camera_ios,
                      color: AppColors.eggshellColor,
                    ),
                    onPressed: () async {
                      await _controller?.flipCamera();
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.pause,
                      color: AppColors.eggshellColor,
                    ),
                    onPressed: () async {
                      await _controller?.pauseCamera();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: AppColors.eggshellColor,
                    ),
                    onPressed: () async {
                      await _controller?.resumeCamera();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: AppColors.verdigrisColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Permission'),
        ),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      String? rawData = scanData.code;
      List<List<dynamic>> csvData = const CsvToListConverter().convert(rawData);
      debugPrint(csvData.toString());

      List<String> headers = List.castFrom(csvData.first);
      debugPrint(csvData.toString());
      await _createTableInDatabase(headers);
      List<Map<String, dynamic>> rows = [];
      for (var row in csvData.skip(1)) {
        Map<String, dynamic> rowData = {};
        for (var i = 0; i < headers.length; i++) {
          rowData[headers[i]] = row[i];
        }
        rows.add(rowData);
      }
      await _insertDataIntoDatabase(headers, rows);
    });
  }

  Future<void> _createTableInDatabase(List<String> headers) async {
    Database db = await DatabaseManager.database;
    String createTableQuery =
        'CREATE TABLE IF NOT EXISTS information (id INTEGER PRIMARY KEY, ';
    for (String header in headers) {
      createTableQuery += '$header TEXT, ';
    }
    createTableQuery =
        createTableQuery.substring(0, createTableQuery.length - 2);
    createTableQuery += ')';
    await db.execute(createTableQuery);
  }

  Future<void> _insertDataIntoDatabase(
      List<String> headers, List<Map<String, dynamic>> rows) async {
    Database db = await DatabaseManager.database;

    for (var row in rows) {
      await db.insert('information', row);
    }
  }
}
