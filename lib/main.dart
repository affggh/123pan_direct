import 'package:a123pan_direct_download/page_home.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool skipLogin = false;

  @override
  void initState() {
    super.initState();
    _checkTokens();
  }

  void _checkTokens() async {
    var pref = await SharedPreferences.getInstance();

    // TODO: Check time stamp

    if (pref.containsKey('tokens')) {
      setState(() {
        skipLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
        return MaterialApp(
      //home: MyAppHome(),
      home: MyAppHome(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
    );
  }
}
