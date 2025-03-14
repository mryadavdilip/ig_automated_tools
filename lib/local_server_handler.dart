import 'dart:isolate';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ftp_server/ftp_server.dart';
import 'package:ftp_server/server_type.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_gallery/hive_handler.dart';

class LocalServerHandler {
  // Make singleton
  static final LocalServerHandler _instance = LocalServerHandler._internal();
  LocalServerHandler._internal();
  factory LocalServerHandler() {
    return _instance;
  }

  FtpServer? ftpServer;
  Isolate? isolate;
  ReceivePort? receivePort;
  int? port;

  Future<void> _requestPermission() async {
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      await Permission.accessMediaLocation.request();
      await Permission.photos.request();
      await Permission.videos.request();
    }
  }

  Future<String?> _getIpAddress() async {
    return await NetworkInfo().getWifiIP();
  }

  Future<String?> pickDirectory({bool change = true}) async {
    await _requestPermission();
    if (await Permission.manageExternalStorage.isPermanentlyDenied ||
        await Permission.manageExternalStorage.isDenied) {
      Fluttertoast.showToast(msg: 'Storage permission denied');
      return null;
    }

    String? savedPath = await HiveHandler.getLocalServerDirectory();
    if (savedPath != null && !change) {
      return savedPath;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      savedPath = await HiveHandler.setLocalServerDirectory(selectedDirectory);
      return savedPath;
    }

    Fluttertoast.showToast(msg: 'No directory was selected');
    return null;
  }

  Future<void> toggleServer() async {
    String? serverDirectory = await pickDirectory(change: false);

    if (serverDirectory == null) return;

    var server = FtpServer(
      port ?? Random().nextInt(65535),
      sharedDirectories: [serverDirectory],
      serverType: ServerType.readAndWrite,
      logFunction: (p0) => debugPrint(p0),
    );

    ftpServer = server;
    var address = await _getIpAddress();

    Clipboard.setData(
      ClipboardData(text: 'ftp://$address:${server.port}'),
    ).then((_) {
      Fluttertoast.showToast(
        msg: 'Server is running, address copied to clipboard',
      );
    });

    server.start();

    return;
  }

  void dispose() async {
    receivePort?.close();
    isolate?.kill(priority: Isolate.immediate);
  }
}
