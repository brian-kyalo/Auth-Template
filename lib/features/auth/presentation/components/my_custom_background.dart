import 'package:flutter/material.dart';

class MyCustomBackground extends StatelessWidget {
  final Widget child;
  const MyCustomBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,

          colors: [
            Color(0xFF0F2027), // deep blue
            Color(0xFF203A43), // tealish blue
            Color(0xFF2C5364), // light bluish
          ],
        ),
      ),

      child: child,
    );
  }
}
