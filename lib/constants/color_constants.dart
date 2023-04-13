import 'dart:ui';

import 'package:flutter/material.dart';

class ColorConstants {
  static const themeColor = Color(0xff57b79b);
  static Map<int, Color> swatchColor = {
    50: themeColor.withOpacity(0.1),
    100: themeColor.withOpacity(0.2),
    200: themeColor.withOpacity(0.3),
    300: themeColor.withOpacity(0.4),
    400: themeColor.withOpacity(0.5),
    500: themeColor.withOpacity(0.6),
    600: themeColor.withOpacity(0.7),
    700: themeColor.withOpacity(0.8),
    800: themeColor.withOpacity(0.9),
    900: themeColor.withOpacity(1),
  };
  static MaterialColor kToDark = MaterialColor(
    0xff57b79b,
    <int, Color>{
      50: const Color(0xff006d38), //10%
      100: const Color(0xff006d38), //20%
      200: const Color(0xff006d38), //30%
      300: const Color(0xff006d38), //40%
      400: const Color(0xff006d38), //50%
      500: const Color(0xff57b79b), //60%
      600: const Color(0xff006d38), //70%
      700: const Color(0xff006d38), //80%
      800: const Color(0xff006d38), //90%
      900: const Color(0xff006d38), //100%
    },
  );
  static const primaryColor = Color(0xff57b79b);
  static const buttonColor = Color(0xffede64f);
  static const greyColor = Color(0xffaeaeae);
  static const greyColor2 = Color(0xffE8E8E8);
}
