import 'package:hive/hive.dart';
import 'package:ig_automated_tools/models/media_file_model.dart';
import 'package:path_provider/path_provider.dart';

enum HiveBoxName { myBox }

enum HiveBoxField { sharedMediaFiles }

class HiveHandler {
  static Future<void> initHive() async {
    String path = (await getApplicationDocumentsDirectory()).path;
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

  static Future<void> addFiles(List<MediaFileModel> files) async {
    LazyBox<List<MediaFileModel>> myBox = await getBox<List<MediaFileModel>>(
      HiveBoxName.myBox.name,
    );

    List<MediaFileModel> temp =
        myBox.containsKey(HiveBoxField.sharedMediaFiles.name)
            ? await myBox.get(HiveBoxField.sharedMediaFiles.name) ?? []
            : [];

    temp.addAll(files);
    await myBox.put(HiveBoxField.sharedMediaFiles.name, temp);
  }
}
