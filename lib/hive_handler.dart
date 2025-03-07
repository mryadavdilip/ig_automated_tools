import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:ig_automated_tools/models/media_file_model.dart';
import 'package:path_provider/path_provider.dart';

enum HiveBoxName { myBox }

enum HiveBoxField { sharedMediaFiles }

class HiveHandler {
  static String documentsDirectory = '';

  static Future<void> initHive() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    documentsDirectory = path;
    Hive
      ..init(path)
      ..registerAdapter<MediaFileModel>(MediaFileModelAdapter())
      ..registerAdapter<SharedMediaType>(SharedMediaTypeAdapter());
  }

  static Future<Box> getBox() async {
    return Hive.isBoxOpen(HiveBoxName.myBox.name)
        ? Hive.box(HiveBoxName.myBox.name)
        : await Hive.openBox(HiveBoxName.myBox.name);
  }

  static Future<void> addFiles(List<MediaFileModel> files) async {
    Box myBox = await getBox();

    List<MediaFileModel> temp = List<MediaFileModel>.from(
      myBox.containsKey(HiveBoxField.sharedMediaFiles.name)
          ? await myBox.get(HiveBoxField.sharedMediaFiles.name) ?? []
          : [],
    );

    for (var item in files) {
      File file = File(item.path);
      if (await file.exists()) {
        if (kDebugMode) {
          print('file ${file.path} found');
        }
        await file.copy('$documentsDirectory/${item.name}');
      } else {
        if (kDebugMode) {
          print('file ${file.path} not found');
        }
      }
    }

    temp.addAll(
      List<MediaFileModel>.from(
        files.map((e) {
          Map<String, dynamic> map = e.toMap();
          map['path'] = '$documentsDirectory/${e.name}';
          return MediaFileModel.fromMap(map);
        }),
      ),
    );
    await myBox.put(HiveBoxField.sharedMediaFiles.name, temp);

    Fluttertoast.showToast(msg: 'Files added');
  }

  static Future<void> removeFile(MediaFileModel file) async {
    Box myBox = await getBox();

    List<MediaFileModel> temp = List<MediaFileModel>.from(
      myBox.containsKey(HiveBoxField.sharedMediaFiles.name)
          ? await myBox.get(HiveBoxField.sharedMediaFiles.name) ?? []
          : [],
    );

    for (var item in temp) {
      if (item.path == file.path) {
        try {
          File localFile = File(item.path);
          if (await localFile.exists()) {
            await localFile.delete();
            log('file deleted');
          } else {
            Fluttertoast.showToast(msg: 'file doesn\'t exists');
          }
        } catch (e) {
          Fluttertoast.showToast(msg: 'Error deleting file ${item.path}');
        }
      }
    }

    temp.removeWhere((element) => element.path == file.path);
    await myBox.put(HiveBoxField.sharedMediaFiles.name, temp);
    Fluttertoast.showToast(msg: 'file deleted');
  }

  static Future<List<MediaFileModel>> getFiles() async {
    Box myBox = await getBox();

    List<MediaFileModel> temp = List<MediaFileModel>.from(
      myBox.containsKey(HiveBoxField.sharedMediaFiles.name)
          ? await myBox.get(HiveBoxField.sharedMediaFiles.name) ?? []
          : [],
    );

    return temp;
  }
}
