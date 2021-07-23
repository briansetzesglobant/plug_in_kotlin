import 'dart:async';
import 'package:flutter/services.dart';
import 'utils/strings.dart';

class PlugInKotlin {
  static const MethodChannel _channel = const MethodChannel(Strings.plug_in);

  static Future<String> get platformVersion async =>
      await _channel.invokeMethod(Strings.getPlatformVersion);

  static Future<bool> get initializeLocatorPlugin async =>
      await _channel.invokeMethod(Strings.initializeLocatorPlugin);

  static Future<bool> get checkPermissions async =>
      await _channel.invokeMethod(Strings.checkPermissions);

  static Future<void> get requestPermissions async {
    await _channel.invokeMethod(Strings.requestPermissions);
    return;
  }

}
