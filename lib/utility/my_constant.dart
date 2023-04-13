import 'package:flutter/material.dart';

class MyConstant {
  // Genernal
  static String appName = 'Exchange';

  // Route
  static String routeLogin = '/Login';
  static String routeCreateAccount = '/CreateAccount';
  static String routeHomePage = '/HomePage';
  static String routeProduct = '/Product';

  // Image
  static String image1 = 'assets/logo.png';
  static String image2 = 'assets/LocationOffline.png';

  // Color
  static Color primary = Color(0xff57b79b);
  static const buttonColor = Color(0xffede64f);
  static Color dark = Color.fromARGB(255, 73, 75, 78);
  static Color light = Color.fromARGB(255, 103, 105, 109);

  // Style
  TextStyle h1Style() => TextStyle(
        fontSize: 24,
        color: dark,
        fontWeight: FontWeight.bold,
      );
  TextStyle h2Style() => TextStyle(
        fontSize: 18,
        color: dark,
        fontWeight: FontWeight.w700,
      );
  TextStyle h3Style() => TextStyle(
        fontSize: 16,
        color: dark,
        fontWeight: FontWeight.normal,
      );

  ButtonStyle myButtonStyle() => ElevatedButton.styleFrom(
        primary: MyConstant.buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      );
}
