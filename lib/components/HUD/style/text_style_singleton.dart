import 'package:flutter/material.dart';

class TextStyleSingleton {
  // Unique instance singleton
  static final TextStyleSingleton _instance = TextStyleSingleton._internal();

  // Private constructor
  TextStyleSingleton._internal();

  // Function to access the singleton instance
  factory TextStyleSingleton() {
    return _instance;
  }

  // Function to get the text style
  TextStyle get style {
    return const TextStyle(fontFamily: 'ArcadeClassic', color: Colors.white);
  }
}
