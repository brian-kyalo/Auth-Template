import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType; // optional
  final int? maxLength; // optional

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        // border when selected
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),

        // border when unselected
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
        fillColor: Colors.transparent,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        counterText: "", // hide counter if you don’t want it
      ),
    );
  }
}
