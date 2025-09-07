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
      appBar: AppBar(
        title: const Text('Setup MFA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Show confirmation dialog before going back
            _showBackConfirmationDialog();
          },
        ),
      ),
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
          } else if (state is Unauthenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
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
              const SizedBox(height: 8),
              Text(
                'Multi-factor authentication adds an extra layer of security',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
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
                    Text(
                      'Enter the 6-digit code sent to ${_phoneController.text}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
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
    if (!_phoneController.text.startsWith('+')) {
      setState(
        () => _error = 'Phone number must include country code (+254...)',
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

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
      setState(() => _error = 'Please enter a valid 6-digit code');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

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
      _error = null;
    });
  }

  void _showBackConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Skip MFA Setup?'),
          content: const Text(
            'Multi-factor authentication provides additional security for your account. Are you sure you want to skip this step?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Setup'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().returnToAuth();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Skip for Now'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
