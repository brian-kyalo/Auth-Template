import 'package:flutter/material.dart';

class ItnroButtons extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const ItnroButtons({super.key, this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.9,
            ),
            //Button color
            color: Theme.of(context).colorScheme.primary,

            //Borderradius
            borderRadius: BorderRadius.circular(12),
          ),
          height: 72,
          padding: const EdgeInsets.all(12),

          child: Center(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }
}
