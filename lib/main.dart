import 'package:flutter/material.dart';
import 'package:ig_automated_tools/hive_handler.dart';
import 'package:ig_automated_tools/home_page.dart';

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
