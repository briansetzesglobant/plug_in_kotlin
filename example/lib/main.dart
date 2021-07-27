import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:plug_in_kotlin/plug_in_kotlin.dart';

import 'utils/strings.dart';
import 'utils/text_styles.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = Strings.valueUnknown;
  bool _initializeLocatorPlugin = false;
  bool _checkPermissions = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await PlugInKotlin.platformVersion;
    } on PlatformException {
      platformVersion = Strings.failedPlatformVersion;
    }
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> initializeLocatorPlugin() async {
    bool _initialize = false;
    try {
      _initialize = await PlugInKotlin.initializeLocatorPlugin;
    } on PlatformException {
      print(Strings.failedInitializeLocatorPlugin);
    }
    _initializeLocatorPlugin = _initialize;
  }

  Future<void> checkPermissions() async {
    bool _check = false;
    try {
      _check = await PlugInKotlin.checkPermissions;
    } on PlatformException {
      print(Strings.failedCheckPermissions);
    }
    _checkPermissions = !_check;
  }

  Future<void> requestPermissions() async {
    try {
      await PlugInKotlin.requestPermissions;
    } on PlatformException {
      print(Strings.failedRequestPermissions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
          title: const Text(Strings.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        initPlatformState();
                      });
                    },
                    child: Text(
                      Strings.textPlatformVersion,
                      style: TextStyles.styleButton,
                    ),
                  ),
                  Text(
                    _platformVersion,
                    style: TextStyles.styleText,
                  ),
                ],
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        initializeLocatorPlugin();
                      });
                    },
                    child: Text(
                      Strings.textInitializeLocatorPlugin,
                      style: TextStyles.styleButton,
                    ),
                  ),
                  Text(
                    '${_initializeLocatorPlugin ? Strings.textInitializeLocatorPluginInitialized : Strings.textInitializeLocatorPluginNotInitialized}',
                    style: TextStyles.styleText,
                  ),
                ],
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        checkPermissions();
                      });
                    },
                    child: Text(
                      Strings.textCheckPermissions,
                      style: TextStyles.styleButton,
                    ),
                  ),
                  Text(
                    '${_checkPermissions ? Strings.textCheckPermissionsGranted : Strings.textCheckPermissionsNotGranted}',
                    style: TextStyles.styleText,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  requestPermissions();
                },
                child: Text(
                  Strings.textRequestPermissions,
                  style: TextStyles.styleButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
