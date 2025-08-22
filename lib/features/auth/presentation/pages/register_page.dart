import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter/features/auth/presentation/components/my_button.dart';
import 'package:starter/features/auth/presentation/components/my_textfield.dart';
import 'package:starter/features/auth/presentation/cubits/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final confirmPassController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  //Register button pressed
  void register() {
    //info
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmpass = confirmPassController.text;

    //Auth cubit
    final authCubit = context.read<AuthCubit>();

    //Ensure fields are not empty
    if (email.isNotEmpty &&
        name.isNotEmpty &&
        password.isNotEmpty &&
        confirmpass.isNotEmpty) {
      //Ensure pass match
      if (password == confirmpass) {
        authCubit.register(name, email, password);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Passwords dont match!")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all fields!")));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    emailController.dispose();
    super.dispose();
  }

  //Register-UI
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
              const SizedBox(height: 8),
              //Logo
              Image.asset(
                width: 320,
                height: 320,
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/2.png' // Darkmode logo.
                    : 'assets/1.png', // Lighmode logo.
              ),

              //Spacing
              const SizedBox(height: 8),

              //Name pass textfield
              MyTextfield(
                controller: nameController,
                hintText: "Name",
                obscureText: false,
              ),

              const SizedBox(height: 8),

              //Email pass textfield
              MyTextfield(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),

              //Spacing
              const SizedBox(height: 8),

              //pass textfield
              MyTextfield(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),

              //Spacing
              const SizedBox(height: 8),

              //pass textfield confirm
              MyTextfield(
                controller: confirmPassController,
                hintText: "Confirm Password",
                obscureText: true,
              ),

              //Spacing
              const SizedBox(height: 8),

              //Login Button
              MyButton(onTap: register, text: "SIGN UP"),

              //
              const SizedBox(height: 4),

              // Dont have an account...
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),

                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      " Sign-in now!",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
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
