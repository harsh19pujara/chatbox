import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 56, color: Colors.white),
        headlineMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 32,color: Colors.black),
        headlineSmall: TextStyle(fontSize: 16, color: Colors.white),
        titleLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: CustomColor.white
        ),
        titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w500,color: Colors.black),
        bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,color: Colors.black),
        bodyMedium: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.black),
        bodySmall: TextStyle(fontSize: 12,color: Colors.black),
      ),

      inputDecorationTheme: const InputDecorationTheme(labelStyle: TextStyle(fontSize: 16,color: CustomColor.authenticationLabel),),
      appBarTheme: const AppBarTheme(
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );

  }
}

class CustomColor {

  static const white = Color(0xFFFFFFFF); //white
  static const authenticationBackground = Color(0xFFFFFFFF); //white
  static const authenticationLabel = Color(0xFF24786D);
  static const authenticationButtonText = Color(0xFFFFFFFF); //white
  static const authenticationButtonColor = Color(0xFF24786D);
  static const friendColor = Color(0xFFa8e5f0); // bluish
  static const userColor =Color(0xFFb3f2c7); // greenish
static const unreadMsg =  Color(0xFFF04A4C);
  static const online =  Color(0xFF0FE16D);
  static const offline =  Color(0xFF9E9E9E);




// static const authenticationVisibilityIcon = Colors.white;
}
