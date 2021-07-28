import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plug_in_kotlin/plug_in_kotlin.dart';

import 'coordinates.dart';
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
  var _coordinates;

  @override
  void initState() {
    super.initState();
    _coordinates = Coordinates();
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
    bool initialize = false;
    try {
      initialize = await PlugInKotlin.initializeLocatorPlugin;
    } on PlatformException {
      print(Strings.failedInitializeLocatorPlugin);
    }
    _initializeLocatorPlugin = initialize;
  }

  Future<void> checkPermissions() async {
    bool check = false;
    try {
      check = await PlugInKotlin.checkPermissions;
    } on PlatformException {
      print(Strings.failedCheckPermissions);
    }
    _checkPermissions = !check;
  }

  Future<void> requestPermissions() async {
    try {
      await PlugInKotlin.requestPermissions;
    } on PlatformException {
      print(Strings.failedRequestPermissions);
    }
  }

  Future<void> returnLastCoordinates() async {
    try {
      await PlugInKotlin.returnLastCoordinates;
    } on PlatformException {
      print(Strings.failedReturnLastCoordinates);
    }
  }

  Future<void> stopLocatorPlugin() async {
    try {
      await PlugInKotlin.stopLocatorPlugin;
    } on PlatformException {
      print(Strings.failedStopLocatorPlugin);
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
              TextButton(
                onPressed: () {
                  returnLastCoordinates();
                },
                child: Column(
                  children: [
                    Text(
                      Strings.textReturnLastCoordinates,
                      style: TextStyles.styleButton,
                    ),
                    StreamBuilder<dynamic>(
                      stream: PlugInKotlin.locationEventStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _coordinates.setCoordinates(snapshot.data);
                        }
                        return Column(
                          children: [
                            Text(
                              _coordinates.latitude,
                              style: TextStyles.styleText,
                            ),
                            Text(
                              _coordinates.longitude,
                              style: TextStyles.styleText,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  stopLocatorPlugin();
                },
                child: Text(
                  Strings.textStopLocatorPlugin,
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
