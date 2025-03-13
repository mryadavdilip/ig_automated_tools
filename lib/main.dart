import 'package:flutter/material.dart';
import 'package:smart_gallery/hive_handler.dart';
import 'package:smart_gallery/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHandler.initHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
