import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_gallery/chatgpt_handler.dart';
import 'package:smart_gallery/local_server_handler.dart';
import 'package:smart_gallery/hive_handler.dart';
import 'package:smart_gallery/infra/utils.dart';
import 'package:smart_gallery/instagram_handler.dart';
import 'package:smart_gallery/instagram_page.dart';
import 'package:smart_gallery/models/media_file_model.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart' as rsi;
import 'package:smart_gallery/models/meta_models/accounts.dart';
import 'package:smart_gallery/models/meta_models/fb_instagram_business_account.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

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

  server() async {
    HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
    server.listen((req) {
      req.response
        ..write('Oho')
        ..close();
    });

    Fluttertoast.showToast(
      msg: 'listening at ${await NetworkInfo().getWifiIP()}:8080',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(onPressed: server, child: Text('server')),
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
                        onPressed: _hostOrStopDirectory,
                        child: Icon(
                          LocalServerHandler().ftpServer == null
                              ? Icons.storage_sharp
                              : Icons.stop,
                        ),
                      )
                      : ElevatedButton(
                        onPressed: _hostOrStopSelectedFiles,
                        child: Icon(
                          LocalServerHandler().ftpServer == null
                              ? Icons.create_new_folder_outlined
                              : Icons.stop,
                        ),
                      ),
                  Spacer(),
                  selectedFiles.isEmpty
                      ? ElevatedButton(
                        onPressed: _clearAllFiles,
                        child: const Text('Clear all files'),
                      )
                      : IconButton(
                        onPressed: _deleteSelectedFiles,
                        icon: Icon(Icons.delete),
                      ),
                  Spacer(),
                  IconButton(
                    onPressed: _showPopupMenu,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Spacer(),
                    Text('Saved Files'),
                    Spacer(),
                    IconButton(
                      onPressed: () async {
                        await LocalServerHandler().requestPermission();
                        FilePicker.platform.pickFiles(allowMultiple: true).then(
                          (v) async {
                            if (v == null) return;

                            await HiveHandler.addFiles(
                              v.files.map((e) {
                                String extension =
                                    e.path!.split('/').last.split('.').last;
                                SharedFileType? type;
                                if (FileExtentions.commonVideoFileExtentions
                                    .contains(extension)) {
                                  type = SharedFileType.video;
                                } else if (FileExtentions.commonImageExtensions
                                    .contains(extension)) {
                                  type = SharedFileType.image;
                                } else {
                                  type = SharedFileType.file;
                                }
                                return MediaFileModel(
                                  path: e.path!,
                                  type: type,
                                );
                              }).toList(),
                            );
                            setState(() {});
                          },
                        );
                      },
                      icon: Icon(Icons.attach_file),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                future: HiveHandler.getFiles(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      (snapshot.data?.isNotEmpty ?? false)) {
                    bool isSelectedAll = true;
                    for (var savedFile in snapshot.data!) {
                      if (!selectedFiles.contains(savedFile)) {
                        isSelectedAll = false;
                        break;
                      }
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            if (selectedFiles.isNotEmpty)
                              IconButton(
                                onPressed: _shareFiles,
                                icon: Icon(Icons.share),
                              ),
                            SizedBox(width: 30),
                            if (selectedFiles.isNotEmpty)
                              Checkbox(
                                value: isSelectedAll,
                                onChanged: (_) {
                                  if (isSelectedAll) {
                                    selectedFiles.clear();
                                  } else {
                                    selectedFiles.clear();
                                    selectedFiles.addAll(snapshot.data!);
                                  }
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 500,
                          width: 300,
                          child: ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () async {
                                  var item = snapshot.data![index];
                                  if (selectedFiles.isNotEmpty) {
                                    selectedFiles.contains(item)
                                        ? selectedFiles.remove(item)
                                        : selectedFiles.add(item);
                                    setState(() {});
                                  } else {
                                    if (item.type == SharedFileType.text ||
                                        item.type == SharedFileType.url) {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              await File(
                                                item.path,
                                              ).readAsString(),
                                        ),
                                      ).then((_) {
                                        Fluttertoast.showToast(
                                          msg:
                                              'Text/Url Content copied to clipboard',
                                        );
                                      });
                                    } else {
                                      OpenFile.open(item.path);
                                    }
                                  }
                                },
                                onLongPress: () async {
                                  var item = snapshot.data![index];

                                  selectedFiles.contains(item)
                                      ? selectedFiles.remove(item)
                                      : selectedFiles.add(item);
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
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No files available'));
                  }
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
    LocalServerHandler().dispose();
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

    // upload to firebase storage
    var uploadingFiles = files.map(
      (file) =>
          storage.ref('SmartGallery').child(file.name).putFile(File(file.path)),
    );

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) {
        List<String?> completed = [];
        List<String?> canceledOrError = [];

        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Uploading to storage...\t${completed.toSet().length}/${uploadingFiles.length}',
                  ),
                  ...uploadingFiles.map(
                    (uploadTask) => StreamBuilder(
                      stream: uploadTask.asStream(),
                      builder: (_, snapshot) {
                        String? name = snapshot.data?.metadata?.name;
                        if (snapshot.data != null) {
                          if (snapshot.data?.state == TaskState.success &&
                              !completed.contains(name)) {
                            completed.add(name);
                          } else if ((snapshot.data?.state ==
                                      TaskState.canceled ||
                                  snapshot.data?.state == TaskState.error) &&
                              !canceledOrError.contains(name)) {
                            canceledOrError.add(name);
                          }

                          if (completed.toSet().length +
                                  canceledOrError.toSet().length ==
                              uploadingFiles.length) {
                            Navigator.pop(context);
                          }
                        }

                        return Row(
                          children: [
                            Text('$name'),
                            Spacer(),
                            CircularProgressIndicator(
                              value:
                                  (snapshot.data?.bytesTransferred ?? 0) /
                                  (snapshot.data?.totalBytes ?? 0),
                            ),
                            switch (snapshot.data?.state ?? TaskState.running) {
                              TaskState.canceled => Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              TaskState.error => Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                              TaskState.paused => Row(
                                children: [
                                  IconButton(
                                    onPressed: uploadTask.resume,
                                    icon: Icon(
                                      Icons.play_arrow,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: uploadTask.cancel,
                                    icon: Icon(
                                      Icons.cancel,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ],
                              ),
                              TaskState.running => Row(
                                children: [
                                  IconButton(
                                    onPressed: uploadTask.pause,
                                    icon: Icon(Icons.stop, color: Colors.green),
                                  ),
                                  IconButton(
                                    onPressed: uploadTask.cancel,
                                    icon: Icon(
                                      Icons.cancel,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ],
                              ),
                              TaskState.success => Icon(
                                Icons.done,
                                color: Colors.blue,
                              ),
                            },
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    List<MediaFileModel?> uploadedFiles = []; // {mediaFileModel, url}
    for (UploadTask uploadTask in uploadingFiles) {
      TaskSnapshot snapshot = await uploadTask.asStream().last;
      if (snapshot.state == TaskState.success) {
        uploadedFiles.add(
          files.where((f) => f.name == snapshot.ref.name).firstOrNull
            ?..message = await snapshot.ref.getDownloadURL(),
        );
      }
    }

    // Post files to Instagram
    for (MediaFileModel? file in uploadedFiles) {
      //
      if (file == null) continue;
      await InstagramAPIs().upload(file);
      // await HiveHandler.removeFile(file);
    }
    setState(() {});
  }

  void _processFiles() async {
    for (var e in selectedFiles) {
      ChatgptHandler().getChatResponse(
        await File(e.path).readAsString(),
      ); // todo: complete this
    }
  }

  void _hostOrStopDirectory() async {
    if (LocalServerHandler().ftpServer == null) {
      await LocalServerHandler().toggleServer();
    } else {
      await LocalServerHandler().stopServer();
    }
    setState(() {});
  }

  void _hostOrStopSelectedFiles() async {
    if (LocalServerHandler().ftpServer == null) {
      String? directory = await LocalServerHandler().pickDirectory();
      if (directory == null) return;

      for (var file in selectedFiles) {
        await File(file.path)
            .copy('${await HiveHandler.getLocalServerDirectory()}/${file.name}')
            .then((file) async {
              await HiveHandler.addCopiedFileEntry(file.path);
            });
      }
      await LocalServerHandler().toggleServer();
    } else {
      await LocalServerHandler().stopServer();
    }

    setState(() {});
  }

  void _clearAllFiles() async {
    await HiveHandler.getFiles().then((v) async {
      for (var e in v) {
        await HiveHandler.removeFile(e);
      }
    });
    setState(() {});
  }

  void _deleteSelectedFiles() async {
    for (var file in selectedFiles) {
      await HiveHandler.removeFile(file);
    }
    selectedFiles.clear();
    setState(() {});
  }

  void _shareFiles() async {
    List<MediaFileModel> urls =
        selectedFiles.where((e) => e.type == SharedFileType.url).toList();
    List<MediaFileModel> texts =
        selectedFiles.where((e) => e.type == SharedFileType.text).toList();
    List<MediaFileModel> files = selectedFiles;

    files.removeWhere((e) => urls.contains(e) || texts.contains(e));

    if (files.isNotEmpty) {
      await Share.shareXFiles(files.map((e) => XFile(e.path)).toList());
    }

    if (urls.isNotEmpty) {
      await Share.share(urls.join(' ||| '));
    }

    if (texts.isNotEmpty) {
      await Share.share(texts.join(' ||| '));
    }
  }

  void _showPopupMenu() {
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
          onTap: _showUserFBAccounts,
          child: Text('Facebook Accounts'),
        ),
        PopupMenuItem(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InstagramPage()),
            );
          },
          child: Text('Instagram'),
        ),
        PopupMenuItem(
          onTap: LocalServerHandler().pickDirectory,
          child: Text('Change Local Server Directory'),
        ),
        PopupMenuItem(
          onTap: _clearCopiedFiles,
          child: Text('Clear copied files'),
        ),
        PopupMenuItem(
          onTap: _hostMultipleDirectories,
          child: Text('Host Multiple Directories'),
        ),
        PopupMenuItem(onTap: _showOpenAIKeys, child: Text('OpenAI API keys')),
        PopupMenuItem(onTap: _showAbout, child: Text('About')),
      ],
    );
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
                      FBAccountData? account = fbAccounts.data[index];
                      return Row(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 150),
                            child: ListTile(
                              onTap: () async {
                                await HiveHandler.setFBAccount(account);

                                if (!mounted) return;
                                Navigator.pop(context);

                                await _showInstagramAccounts();
                              },
                              title: Text(account.name),
                              subtitle: GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: account.id),
                                  );
                                  Fluttertoast.showToast(
                                    msg: 'Account id copied to clipboard',
                                  );
                                },
                                child: Text(account.id),
                              ),
                              selected: selectedFBAccount?.id == account.id,
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
                          await HiveHandler.setIGAccount(instagramAccount);

                          if (!mounted) return;
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        title: Text(instagramAccount.id),
                        subtitle: GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text:
                                    instagramAccount
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
                            selectedIGAccount?.instagramBusinessAccount.id ==
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

  void _clearCopiedFiles() {
    HiveHandler.getHostedCopiedFilesEntries().then((entries) async {
      for (var element in entries) {
        if (await File(element).exists()) {
          File(element).delete().then((fse) async {
            if (!await fse.exists()) {
              HiveHandler.deleteCopiedFileEntry(element);
            }
          });
        }
      }
    });
  }

  void _hostMultipleDirectories() {
    List<String> directories = [];
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (ctx, setStat) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Host multiple directories'),
                        SizedBox(height: 30),
                        Wrap(
                          children: [
                            ...directories.map(
                              (e) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 220),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      reverse: true,
                                      child: Text(e),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      directories.remove(e);
                                      setStat(() {});
                                    },
                                    icon: Icon(Icons.remove),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            MaterialButton(
                              onPressed: () async {
                                await LocalServerHandler().requestPermission();
                                if (await Permission
                                        .manageExternalStorage
                                        .isPermanentlyDenied ||
                                    await Permission
                                        .manageExternalStorage
                                        .isDenied) {
                                  Fluttertoast.showToast(
                                    msg: 'Storage permission denied',
                                  );
                                  return;
                                }

                                String? path =
                                    await FilePicker.platform
                                        .getDirectoryPath();
                                if (path != null) {
                                  directories.add(path);
                                  setStat(() {});
                                }
                              },
                              child: Text('Add directory +'),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        MaterialButton(
                          minWidth: 150,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => Dialog(
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: usernameController,
                                            decoration: InputDecoration(
                                              hintText: 'Username',
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          TextField(
                                            controller: passwordController,
                                            decoration: InputDecoration(
                                              hintText: 'Password',
                                            ),
                                          ),
                                          SizedBox(),
                                          MaterialButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Done'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: Text('Require authentication? (optional)'),
                        ),
                        SizedBox(height: 30),
                        MaterialButton(
                          minWidth: 150,
                          onPressed: () async {
                            if (LocalServerHandler().ftpServer == null) {
                              await LocalServerHandler().toggleServer(
                                directories: directories,
                                auth:
                                    usernameController.text.isEmpty ||
                                            passwordController.text.isEmpty
                                        ? null
                                        : Auth(
                                          usernameController.text,
                                          passwordController.text,
                                        ),
                              );
                            } else {
                              await LocalServerHandler().stopServer();
                            }
                            setStat(() {});
                            setState(() {});
                          },
                          child:
                              LocalServerHandler().ftpServer == null
                                  ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Host'),
                                      Icon(Icons.wifi_tethering),
                                    ],
                                  )
                                  : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Stop server'),
                                      Icon(Icons.stop),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
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
