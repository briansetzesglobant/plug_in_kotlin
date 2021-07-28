import 'dart:async';
import 'package:flutter/services.dart';
import 'utils/strings.dart';

class PlugInKotlin {
  static const EventChannel _locationEventChannel =
      const EventChannel(Strings.location_event_channel);

  static Stream<dynamic> get locationEventStream =>
      _locationEventChannel.receiveBroadcastStream();

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

  static Future<Map<dynamic, dynamic>> get returnLastCoordinates async =>
      await _channel.invokeMethod(Strings.returnLastCoordinates);

  static Future<bool> get stopLocatorPlugin async =>
      await _channel.invokeMethod(Strings.stopLocatorPlugin);
}
