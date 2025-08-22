import 'package:flutter/material.dart';

ThemeData darktMode = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Colors.transparent,
    secondary: const Color.fromARGB(255, 10, 159, 223),
    tertiary: Colors.grey.shade900,
    inversePrimary: Colors.grey.shade300,
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
);
