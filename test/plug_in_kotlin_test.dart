import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plug_in_kotlin/plug_in_kotlin.dart';

void main() {
  const MethodChannel channel = MethodChannel('plug_in_kotlin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await PlugInKotlin.platformVersion, '42');
  });
}
