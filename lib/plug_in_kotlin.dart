
import 'dart:async';

import 'package:flutter/services.dart';

class PlugInKotlin {
  static const MethodChannel _channel =
      const MethodChannel('plug_in_kotlin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
