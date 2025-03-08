import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ig_automated_tools/hive_handler.dart';
import 'package:ig_automated_tools/infra/utils.dart';
import 'package:ig_automated_tools/models/media_file_model.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart' as rsi;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _openAIKeyController = TextEditingController();

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
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await HiveHandler.getFiles().then((v) async {
                      for (var e in v) {
                        await HiveHandler.removeFile(e);
                      }
                    });
                    setState(() {});
                  },
                  child: const Text('Clear all files'),
                ),
                ElevatedButton(
                  onPressed: _bulkPost,
                  child: const Text('Bulk post'),
                ),

                IconButton(
                  onPressed: () {
                    showMenu(
                      context: context,
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
                      position: RelativeRect.fromLTRB(200, 0, 0, 600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      items: [
                        PopupMenuItem(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (ctx, setStat) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('OpenAI API keys'),
                                            SizedBox(height: 10),
                                            FutureBuilder(
                                              future:
                                                  HiveHandler.getOpenAIAPIKeys(),
                                              builder: (context, snapshot) {
                                                return snapshot.hasData &&
                                                        (snapshot
                                                                .data
                                                                ?.isNotEmpty ??
                                                            false)
                                                    ? SizedBox(
                                                      height: 600,
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            snapshot
                                                                .data
                                                                ?.length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          return Row(
                                                            children: [
                                                              ConstrainedBox(
                                                                constraints:
                                                                    BoxConstraints(
                                                                      maxWidth:
                                                                          150,
                                                                    ),
                                                                child: ListTile(
                                                                  title: Text(
                                                                    '${snapshot.data?[index].key}',
                                                                  ),
                                                                  selected:
                                                                      !Utils.isDateExpired(
                                                                        snapshot
                                                                            .data![index]
                                                                            .lastUsed,
                                                                      ),
                                                                  onLongPress: () async {
                                                                    await HiveHandler.removeOpenAIAPIKey(
                                                                      snapshot
                                                                          .data![index]
                                                                          .key,
                                                                    );
                                                                    setStat(
                                                                      () {},
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Checkbox(
                                                                value:
                                                                    snapshot
                                                                        .data![index]
                                                                        .shouldUse,
                                                                onChanged: (
                                                                  v,
                                                                ) async {
                                                                  await HiveHandler.enableOrDisableOpenAIAPIKey(
                                                                    snapshot
                                                                        .data![index]
                                                                        .key,
                                                                    !snapshot
                                                                        .data![index]
                                                                        .shouldUse,
                                                                  );
                                                                  setStat(
                                                                    () {},
                                                                  );
                                                                },
                                                              ),
                                                              if (Utils.isDateExpired(
                                                                snapshot
                                                                    .data![index]
                                                                    .lastUsed,
                                                              ))
                                                                Text(
                                                                  Utils.durationToHumanReadable(
                                                                    DateTime.now().difference(
                                                                      snapshot
                                                                          .data![index]
                                                                          .lastUsed,
                                                                    ),
                                                                  ),
                                                                ),
                                                              IconButton(
                                                                onPressed: () async {
                                                                  await HiveHandler.resetLastUsedOpenAIKey(
                                                                    snapshot
                                                                        .data![index]
                                                                        .key,
                                                                  );
                                                                  setStat(
                                                                    () {},
                                                                  );
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .restore_rounded,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    )
                                                    : const Center(
                                                      child: Text(
                                                        'No keys available',
                                                      ),
                                                    );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Text('OpenAI API keys'),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('About'),
                                        SizedBox(height: 10),
                                        Text(
                                          'This app is developed by @mryadavdilip. It is used to automate the process of posting images and videos to Instagram. It uses OpenAI API to generate captions for the media files. The media files can be shared from other apps to this app and then posted to Instagram.',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text('About'),
                        ),
                      ],
                    );
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 270,
                  child: TextField(
                    controller: _openAIKeyController,
                    decoration: const InputDecoration(
                      hintText: 'OpenAI keys (e.g. key1, key2, key3)',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _openAIKeyController.text.split(',').forEach((key) async {
                      await HiveHandler.addOpenAIAPIKey(key.trim());
                    });

                    _openAIKeyController.clear();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            SizedBox(height: 30),
            FutureBuilder(
              future: HiveHandler.getFiles(),
              builder: (context, snapshot) {
                return snapshot.hasData && (snapshot.data?.isNotEmpty ?? false)
                    ? ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('${snapshot.data?[index].name}'),
                          subtitle: Text('${snapshot.data?[index].path}'),
                          onLongPress: () async {
                            await HiveHandler.removeFile(snapshot.data![index]);
                            setState(() {});
                          },
                        );
                      },
                    )
                    : const Center(child: Text('No files available'));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _receiveData(List<rsi.SharedMediaFile> value) async {
    // log('message: ${value.map((e) => e.path).toList()}');

    await HiveHandler.addFiles(
      List<MediaFileModel>.from(
        value.map((e) => MediaFileModel.fromMap(e.toMap())),
      ),
    );
    setState(() {});
  }

  void _bulkPost() async {
    final files = await HiveHandler.getFiles();
    if (files.isEmpty) {
      Fluttertoast.showToast(msg: 'No files available');
      return;
    }

    // Post files
    for (var file in files) {
      // Post file
      // await postFile(file);

      await HiveHandler.removeFile(file);
    }
    setState(() {});
  }

  @override
  void dispose() {
    HiveHandler.dispose();
    super.dispose();
  }
}
