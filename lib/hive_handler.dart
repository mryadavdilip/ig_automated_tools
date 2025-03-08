import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:ig_automated_tools/infra/utils.dart';
import 'package:ig_automated_tools/models/media_file_model.dart';
import 'package:ig_automated_tools/models/open_ai_key_model.dart';
import 'package:path_provider/path_provider.dart';

enum HiveBoxName { myBox }

enum HiveBoxField { sharedMediaFiles, openAIAPIKeys }

class HiveHandler {
  static String documentsDirectory = '';

  static Future<void> initHive() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    documentsDirectory = path;
    Hive
      ..init(path)
      ..registerAdapter<MediaFileModel>(MediaFileModelAdapter())
      ..registerAdapter<SharedFileType>(SharedFileTypeAdapter())
      ..registerAdapter<OpenAIKeyModel>(OpenAIKeyModelAdapter());

    // reset all OpenAI keys lastUsed fields if they are not expired
    await getOpenAIAPIKeys().then((value) {
      for (var element in value) {
        if (!Utils.isDateExpired(element.lastUsed)) {
          resetLastUsedOpenAIKey(element.key);
        }
      }
    });
  }

  static Future<void> dispose() async {
    await Hive.close();
  }

  static Future<Box> _getBox() async {
    return Hive.isBoxOpen(HiveBoxName.myBox.name)
        ? Hive.box(HiveBoxName.myBox.name)
        : await Hive.openBox(HiveBoxName.myBox.name);
  }

  static Future<List<MediaFileModel>> getFiles() async {
    Box myBox = await _getBox();

    return List<MediaFileModel>.from(
      myBox.containsKey(HiveBoxField.sharedMediaFiles.name)
          ? await myBox.get(HiveBoxField.sharedMediaFiles.name) ?? []
          : [],
    );
  }

  static Future<void> addFiles(List<MediaFileModel> files) async {
    Box myBox = await _getBox();

    List<MediaFileModel> temp = await getFiles();

    for (var item in files) {
      File file = File(item.path);
      if (await file.exists()) {
        if (kDebugMode) {
          print('file ${file.path} found');
        }
        if (item.type == SharedFileType.text ||
            item.type == SharedFileType.url) {
          await file.writeAsString(item.path);
        }

        await file.copy('$documentsDirectory/${item.name}');

        await file.delete();
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
    Box myBox = await _getBox();

    List<MediaFileModel> temp = await getFiles();

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

  static Future<OpenAIKeyModel> getOpenAIKey() async {
    List<OpenAIKeyModel> temp =
        (await getOpenAIAPIKeys())
            .where((e) => e.shouldUse && !Utils.isDateExpired(e.lastUsed))
            .toList();
    if (temp.isEmpty) {
      Fluttertoast.showToast(msg: 'No active OpenAI API key found');
      return OpenAIKeyModel(
        key: '',
        lastUsed: DateTime.now(),
        shouldUse: false,
      );
    }

    return temp.first;
  }

  static Future<List<OpenAIKeyModel>> getOpenAIAPIKeys() async {
    Box myBox = await _getBox();

    var temp = List<OpenAIKeyModel>.from(
      myBox.containsKey(HiveBoxField.openAIAPIKeys.name)
          ? await myBox.get(HiveBoxField.openAIAPIKeys.name) ?? []
          : [],
    );

    if (temp.isEmpty) {
      Fluttertoast.showToast(msg: 'No OpenAI API key found');
    }

    return temp;
  }

  static Future addOpenAIAPIKey(String key) async {
    Box myBox = await _getBox();

    List<OpenAIKeyModel> temp = await getOpenAIAPIKeys();
    temp.add(
      OpenAIKeyModel(
        key: key,
        lastUsed: DateTime.fromMillisecondsSinceEpoch(0),
        shouldUse: false,
      ),
    );

    await myBox.put(HiveBoxField.openAIAPIKeys.name, temp);
    Fluttertoast.showToast(msg: 'OpenAI API key added');
  }

  static Future removeOpenAIAPIKey(String key) async {
    Box myBox = await _getBox();

    List<OpenAIKeyModel> temp = await getOpenAIAPIKeys();
    temp.removeWhere((e) => e.key == key);

    await myBox.put(HiveBoxField.openAIAPIKeys.name, temp);
    Fluttertoast.showToast(msg: 'OpenAI API key removed');
  }

  static Future<void> enableOrDisableOpenAIAPIKey(
    String key,
    bool enable,
  ) async {
    try {
      // Get the Hive box that stores the OpenAI API keys
      Box myBox = await _getBox();

      // Retrieve current list of OpenAI keys from your storage
      List<OpenAIKeyModel> keys = await getOpenAIAPIKeys();

      // Find the key and update its 'shouldUse' field
      final keyToUpdate = keys.where((e) => e.key == key).firstOrNull;

      if (keyToUpdate != null) {
        keyToUpdate.shouldUse = enable;

        // Save the updated list back into the box
        await myBox.put(HiveBoxField.openAIAPIKeys.name, keys);

        // Show a toast notification to let the user know the status
        Fluttertoast.showToast(
          msg: 'OpenAI API key ${enable ? 'enabled' : 'disabled'}',
        );
      } else {
        Fluttertoast.showToast(msg: 'API key not found.');
      }
    } catch (e) {
      // Handle any errors that occur
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  static Future<void> resetLastUsedOpenAIKey(String key) async {
    try {
      // Get the Hive box that stores the OpenAI API keys
      Box myBox = await _getBox();

      // Retrieve current list of OpenAI keys from storage
      List<OpenAIKeyModel> keys = await getOpenAIAPIKeys();

      // Find the key and reset the 'lastUsed' field to the Unix epoch (1970-01-01)
      final keyToUpdate = keys.where((e) => e.key == key).firstOrNull;

      if (keyToUpdate != null) {
        keyToUpdate.lastUsed = DateTime.fromMillisecondsSinceEpoch(0);

        // Save the updated list back into the box
        await myBox.put(HiveBoxField.openAIAPIKeys.name, keys);

        // Show a toast notification to let the user know the status
        Fluttertoast.showToast(msg: 'OpenAI API key recovered');
      } else {
        Fluttertoast.showToast(msg: 'API key not found.');
      }
    } catch (e) {
      // Handle any errors that occur
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }
}
