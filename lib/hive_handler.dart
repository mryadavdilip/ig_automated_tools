import 'dart:io';

import 'package:flutter/foundation.dart';
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
      ..registerAdapter<MediaFileModel>(MediaFileModelAdapter(), override: true)
      ..registerAdapter<SharedMediaType>(
        SharedMediaTypeAdapter(),
        override: true,
      );
  }

  static Future<LazyBox<E>> getBox<E>(String boxName) async =>
      Hive.isBoxOpen(boxName)
          ? await Hive.openLazyBox<E>(boxName)
          : Hive.lazyBox<E>(boxName);

  static Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  static Future<void> addFiles(List<MediaFileModel> files) async {
    LazyBox<List<MediaFileModel>> myBox = await getBox<List<MediaFileModel>>(
      HiveBoxName.myBox.name,
    );

    List<MediaFileModel> temp =
        myBox.containsKey(HiveBoxField.sharedMediaFiles.name)
            ? await myBox.get(HiveBoxField.sharedMediaFiles.name) ?? []
            : [];

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

    await myBox.close();
  }

  static Future<void> removeFile(MediaFileModel file) async {
    LazyBox<List<MediaFileModel>> myBox = await getBox<List<MediaFileModel>>(
      HiveBoxName.myBox.name,
    );

    List<MediaFileModel> temp =
        myBox.containsKey(HiveBoxField.sharedMediaFiles.name)
            ? await myBox.get(HiveBoxField.sharedMediaFiles.name) ?? []
            : [];

    for (var item in temp) {
      if (item.path == file.path) {
        await File(item.path).delete();

        temp.remove(item);
      }
    }
    await myBox.put(HiveBoxField.sharedMediaFiles.name, temp);

    await myBox.close();
  }

  static Future<List<MediaFileModel>> getFiles() async {
    LazyBox<List<MediaFileModel>> myBox = await getBox<List<MediaFileModel>>(
      HiveBoxName.myBox.name,
    );

    List<MediaFileModel> temp =
        myBox.containsKey(HiveBoxField.sharedMediaFiles.name)
            ? await myBox.get(HiveBoxField.sharedMediaFiles.name) ?? []
            : [];

    await myBox.close();

    return temp;
  }
}
