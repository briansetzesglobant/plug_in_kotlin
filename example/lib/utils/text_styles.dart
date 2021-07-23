import 'package:flutter/material.dart';
import 'numbers.dart';

abstract class TextStyles {
  static const TextStyle styleButton = TextStyle(
    decoration: TextDecoration.underline,
    fontSize: Numbers.valueStyleButton,
    color: Colors.black,
  );
  static const TextStyle styleText = TextStyle(
    fontSize: Numbers.valueStyleButton,
    color: Colors.yellow,
  );
}
