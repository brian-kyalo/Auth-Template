import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final void Function()? onTap;
  const GoogleSignInButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        ),
        child: Image.asset("assets/g.png", height: 35),
      ),
    );
  }
}
