import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_gallery/chatgpt_handler.dart';
import 'package:smart_gallery/hive_handler.dart';
import 'package:smart_gallery/infra/utils.dart';
import 'package:smart_gallery/instagram_handler.dart';
import 'package:smart_gallery/instagram_page.dart';
import 'package:smart_gallery/models/media_file_model.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart' as rsi;
import 'package:smart_gallery/models/meta_models/accounts.dart';
import 'package:smart_gallery/models/meta_models/fb_instagram_business_account.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _fbAccessTokenController = TextEditingController();
  final _openAIKeyController = TextEditingController();

  List<MediaFileModel> selectedFiles = [];

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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Spacer(),

                  selectedFiles.isEmpty
                      ? ElevatedButton(
                        onPressed: _bulkPost,
                        child: const Text('Bulk post'),
                      )
                      : ElevatedButton(
                        onPressed: _processFiles,
                        child: const Text('Extract -gpt4o'),
                      ),

                  Spacer(),
                  selectedFiles.isEmpty
                      ? ElevatedButton(
                        onPressed: () async {
                          await HiveHandler.getFiles().then((v) async {
                            for (var e in v) {
                              await HiveHandler.removeFile(e);
                            }
                          });
                          setState(() {});
                        },
                        child: const Text('Clear all files'),
                      )
                      : IconButton(
                        onPressed: () async {
                          for (var file in selectedFiles) {
                            await HiveHandler.removeFile(file);
                          }
                          selectedFiles.clear();
                          setState(() {});
                        },
                        icon: Icon(Icons.delete),
                      ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      showMenu(
                        context: context,
                        constraints: BoxConstraints(
                          minWidth: 100,
                          maxWidth: 200,
                        ),
                        position: RelativeRect.fromLTRB(200, 0, 0, 600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        items: [
                          PopupMenuItem(
                            onTap: _showUserFBAccounts,
                            child: Text('Facebook Accounts'),
                          ),
                          PopupMenuItem(
                            onTap: _showOpenAIKeys,
                            child: Text('OpenAI API keys'),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InstagramPage(),
                                ),
                              );
                            },
                            child: Text('Instagram'),
                          ),
                          PopupMenuItem(
                            onTap: _showAbout,
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
                      controller: _fbAccessTokenController,
                      decoration: const InputDecoration(
                        hintText: 'Facebook access token',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await HiveHandler.setFbAccessToken(
                        _fbAccessTokenController.text.trim(),
                      );

                      _fbAccessTokenController.clear();
                    },
                    child: const Text('Save'),
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
                      for (var key in _openAIKeyController.text.split(',')) {
                        await HiveHandler.addOpenAIAPIKey(key.trim());
                      }

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
                  return snapshot.hasData &&
                          (snapshot.data?.isNotEmpty ?? false)
                      ? SizedBox(
                        height: 500,
                        width: 300,
                        child: ListView.builder(
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                selectedFiles.contains(snapshot.data![index])
                                    ? selectedFiles.remove(
                                      snapshot.data![index],
                                    )
                                    : selectedFiles.add(snapshot.data![index]);
                                setState(() {});
                              },
                              onLongPress: () async {
                                await HiveHandler.removeFile(
                                  snapshot.data![index],
                                );
                                selectedFiles.remove(snapshot.data![index]);
                                selectedFiles.clear();
                                setState(() {});
                              },
                              title: Text('${snapshot.data?[index].name}'),
                              subtitle: Text('${snapshot.data?[index].path}'),
                              selected: selectedFiles.contains(
                                snapshot.data![index],
                              ),
                            );
                          },
                        ),
                      )
                      : const Center(child: Text('No files available'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    HiveHandler.dispose();
    super.dispose();
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
    FBAccountData? account = await HiveHandler.getSelectedFBAccount();
    if (account == null) {
      await _showUserFBAccounts();
    }

    final files = await HiveHandler.getFiles();
    if (files.isEmpty) {
      Fluttertoast.showToast(msg: 'No files available');
      return;
    }

    // Post files
    for (var file in files) {
      // await HiveHandler.removeFile(file);
    }
    setState(() {});
  }

  Future<void> _showUserFBAccounts() async {
    if (await HiveHandler.getFbAccessToken() == null) {
      Fluttertoast.showToast(msg: 'Please save facebook access token first');
      return;
    }

    FBAccountData? selectedFBAccount = await HiveHandler.getSelectedFBAccount();
    FBAccounts? fbAccounts = await InstagramAPIs().getFacebookAccounts();

    final Widget dialog = Dialog(
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
            Text('Facebook Accounts'),
            SizedBox(height: 10),
            fbAccounts != null
                ? SizedBox(
                  height: 600,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: fbAccounts.data.length,
                    itemBuilder: (_, index) {
                      FBAccountData? account = fbAccounts?.data[index];
                      return Row(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 150),
                            child: ListTile(
                              onTap: () async {
                                await HiveHandler.setFBAccount(account!);

                                if (!mounted) return;
                                Navigator.pop(context);

                                await _showInstagramAccounts();
                              },
                              title: Text('${account?.name}'),
                              subtitle: GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: '${account?.id}'),
                                  );
                                  Fluttertoast.showToast(
                                    msg: 'Account id copied to clipboard',
                                  );
                                },
                                child: Text('${account?.id}'),
                              ),
                              selected: selectedFBAccount?.id == account?.id,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
                : const Center(child: Text('No facebook accounts available')),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (selectedFBAccount == null) {
      await showDialog(context: context, builder: (_) => dialog);
    } else {
      showDialog(context: context, builder: (_) => dialog);
    }

    if (selectedFBAccount != null) {
      await _showInstagramAccounts();
    }
  }

  Future<void> _showInstagramAccounts() async {
    FbInstagramBusinessAccount? instagramAccount =
        await InstagramAPIs().getInstagramBusinessAccounts();

    FbInstagramBusinessAccount? selectedIGAccount =
        await HiveHandler.getSelectedIGAccount();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) {
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    Text('Instagram Professional Accounts'),
                  ],
                ),
                SizedBox(height: 10),
                instagramAccount != null
                    ? ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 150),
                      child: ListTile(
                        onTap: () async {
                          await HiveHandler.setIGAccount(instagramAccount!);

                          if (!mounted) return;
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        title: Text(instagramAccount.id),
                        subtitle: GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text:
                                    instagramAccount!
                                        .instagramBusinessAccount
                                        .id,
                              ),
                            );
                            Fluttertoast.showToast(
                              msg: 'Instagram account id copied to clipboard',
                            );
                          },
                          child: Text(
                            instagramAccount.instagramBusinessAccount.id,
                          ),
                        ),
                        selected:
                            selectedIGAccount?.id ==
                            instagramAccount.instagramBusinessAccount.id,
                      ),
                    )
                    : const Center(
                      child: Text('Instagram account not available'),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _processFiles() async {
    for (var e in selectedFiles) {
      ChatgptHandler().getChatResponse(await File(e.path).readAsString());
    }
  }

  void _showOpenAIKeys() {
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
                      future: HiveHandler.getOpenAIAPIKeys(),
                      builder: (context, snapshot) {
                        return snapshot.hasData &&
                                (snapshot.data?.isNotEmpty ?? false)
                            ? SizedBox(
                              height: 600,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data?.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 150,
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            '${snapshot.data?[index].key}',
                                          ),
                                          selected:
                                              !Utils.isDateExpired(
                                                snapshot.data![index].lastUsed,
                                              ),
                                          onLongPress: () async {
                                            await HiveHandler.removeOpenAIAPIKey(
                                              snapshot.data![index].key,
                                            );
                                            setStat(() {});
                                          },
                                        ),
                                      ),
                                      Checkbox(
                                        value: snapshot.data![index].shouldUse,
                                        onChanged: (v) async {
                                          await HiveHandler.enableOrDisableOpenAIAPIKey(
                                            snapshot.data![index].key,
                                            !snapshot.data![index].shouldUse,
                                          );
                                          setStat(() {});
                                        },
                                      ),
                                      if (Utils.isDateExpired(
                                        snapshot.data![index].lastUsed,
                                      ))
                                        Text(
                                          Utils.durationToHMS(
                                            DateTime.now().difference(
                                              snapshot.data![index].lastUsed,
                                            ),
                                          ),
                                        ),
                                      IconButton(
                                        onPressed: () async {
                                          await HiveHandler.resetLastUsedOpenAIKey(
                                            snapshot.data![index].key,
                                          );
                                          setStat(() {});
                                        },
                                        icon: Icon(Icons.restore_rounded),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                            : const Center(child: Text('No keys available'));
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
  }

  void _showAbout() {
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
  }
}
