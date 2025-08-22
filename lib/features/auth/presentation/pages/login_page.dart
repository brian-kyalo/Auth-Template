/*
 * This is a basic login page without OAuth or 2 factor authentication.
 * A User Logs in and is directed directly to the homepage.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter/features/auth/presentation/components/my_button.dart';
import 'package:starter/features/auth/presentation/components/my_textfield.dart';
import 'package:starter/features/auth/presentation/cubits/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //Login Button functionallity.
  void login() {
    //prep email and password.
    final String email = emailController.text;
    final String password = passwordController.text;

    //AuthCubit
    final authCubit = context.read<AuthCubit>();

    //Ensure all fields are field
    if (email.isNotEmpty && password.isNotEmpty) {
      //Login
      authCubit.login(email, password);
    }
    //Fields are empty
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email & password")),
      );
    }
  }

  //Login-UI
  @override
  Widget build(BuildContext context) {
    //Scaffold
    return Scaffold(
      //Body
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //
              const SizedBox(height: 15),
              //Logo
              Image.asset(
                width: 320,
                height: 320,
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/2.png' // Darkmode logo.
                    : 'assets/1.png', // Lighmode logo.
              ),

              //Spacing
              const SizedBox(height: 10),

              //Name app

              //Email pass textfield
              MyTextfield(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),

              //Spacing
              const SizedBox(height: 10),

              //pass textfield
              MyTextfield(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),

              //Spacing
              const SizedBox(height: 4),

              //Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),

              //Spacing
              const SizedBox(height: 4),

              //Login Button
              MyButton(onTap: login, text: "LOGIN"),

              //
              const SizedBox(height: 4),

              // Dont have an account...
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dont have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),

                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      " Sign-Up now!",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
