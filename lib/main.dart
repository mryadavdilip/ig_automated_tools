import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ig_automated_tools/hive_handler.dart';
import 'package:ig_automated_tools/models/media_file_model.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart' as rsi;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHandler.initHive();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    rsi.ReceiveSharingIntent.instance.getMediaStream().listen(
      _receiveData,
      onError: (e) {
        if (kDebugMode) {
          print(e);
        }
      },
    );
    rsi.ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _receiveData(value);
      rsi.ReceiveSharingIntent.instance.reset();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: HiveHandler.getFiles(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${snapshot.data?[index].name}'),
                    subtitle: Text('${snapshot.data?[index].path}'),
                  );
                },
              )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  _receiveData(List<rsi.SharedMediaFile> value) async {
    await HiveHandler.addFiles(
      List<MediaFileModel>.from(
        value.map((e) => MediaFileModel.fromMap(e.toMap())),
      ),
    );
  }
}
