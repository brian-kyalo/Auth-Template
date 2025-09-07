import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter/features/auth/domain/entities/app_user.dart';
import 'package:starter/features/auth/presentation/components/my_button.dart';
import 'package:starter/features/auth/presentation/components/my_textfield.dart';
import 'package:starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:starter/features/auth/presentation/cubits/auth_state.dart';
import 'package:starter/features/home/presentation/pages/home_page.dart';

class MfaEnrollmentPage extends StatefulWidget {
  final AppUser user;
  const MfaEnrollmentPage({super.key, required this.user});

  @override
  State<MfaEnrollmentPage> createState() => _MfaEnrollmentPageState();
}

class _MfaEnrollmentPageState extends State<MfaEnrollmentPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup MFA')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (state is AuthError) {
            setState(() {
              _error = state.message;
              _loading = false;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_android, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Add Phone for ${widget.user.email}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              if (_verificationId == null)
                Column(
                  children: [
                    MyTextfield(
                      controller: _phoneController,
                      hintText: 'Phone Number (+254xxxxxxxxx)',
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),
                    MyButton(
                      onTap: _loading ? null : _sendCode,
                      text: _loading ? 'Sending...' : 'Send Code',
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    MyTextfield(
                      controller: _codeController,
                      hintText: 'SMS Code',
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: _resend,
                          child: const Text('Resend'),
                        ),
                        MyButton(
                          onTap: _loading ? null : _verify,
                          text: _loading ? 'Verifying...' : 'Verify',
                        ),
                      ],
                    ),
                  ],
                ),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _error = 'Please enter a phone number');
      return;
    }
    setState(() => _loading = true);
    await context.read<AuthCubit>().sendEnrollmentCode(
      _phoneController.text,
      onCodeSent: (id, _) {
        setState(() {
          _verificationId = id;
          _loading = false;
        });
      },
      onError: (err) {
        setState(() {
          _error = err;
          _loading = false;
        });
      },
    );
  }

  Future<void> _verify() async {
    if (_codeController.text.length != 6 || _verificationId == null) {
      setState(() => _error = 'Invalid code');
      return;
    }
    setState(() => _loading = true);
    await context.read<AuthCubit>().enrollMFA(
      _phoneController.text,
      _codeController.text,
      _verificationId!,
    );
  }

  void _resend() {
    setState(() {
      _verificationId = null;
      _codeController.clear();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
