/*
* Determines wether to show the login or register page.
 */

import 'package:flutter/material.dart';
import 'package:starter/features/auth/presentation/pages/login_page.dart';
import 'package:starter/features/auth/presentation/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Initially show the intro page
  bool showLoginPage = true;

  //Method to toggle between the pages.
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(togglePages: togglePages);
    } else {
      return RegisterPage(togglePages: togglePages);
    }
  }
}
