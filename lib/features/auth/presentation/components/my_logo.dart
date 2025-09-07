import 'package:flutter/material.dart';

Image myLogo(BuildContext context) {
  return Image.asset(
    width: 320,
    height: 320,
    Theme.of(context).brightness == Brightness.dark
        ? 'assets/2.png' // Darkmode logo.
        : 'assets/1.png', // Lighmode logo.
  );
}
