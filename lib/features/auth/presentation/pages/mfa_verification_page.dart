import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter/features/auth/presentation/components/my_button.dart';
import 'package:starter/features/auth/presentation/components/my_textfield.dart';
import 'package:starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:starter/features/auth/presentation/cubits/auth_state.dart';
import 'package:starter/features/home/presentation/pages/home_page.dart';

class MFAVerificationPage extends StatefulWidget {
  const MFAVerificationPage({super.key});

  @override
  State<MFAVerificationPage> createState() => _MFAVerificationPageState();
}

class _MFAVerificationPageState extends State<MFAVerificationPage> {
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _loading = false;
  String? _error;
  int _selectedHintIndex = 0;
  List<String> _hints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify MFA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<AuthCubit>().returnToAuth();
          },
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
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
          } else if (state is MFAVerificationRequired) {
            setState(() {
              _hints = state.hints;
              if (_hints.isNotEmpty && _selectedHintIndex >= _hints.length) {
                _selectedHintIndex = 0;
              }
            });
          }
        },
        builder: (context, state) {
          if (state is! MFAVerificationRequired) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  'Multi-Factor Authentication',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the code sent to your registered phone number',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_hints.length > 1) ...[
                  Text(
                    'Select phone number:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<int>(
                    value: _selectedHintIndex,
                    isExpanded: true,
                    items: _hints.asMap().entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedHintIndex = value;
                          _verificationId = null; // Reset verification
                          _codeController.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ] else if (_hints.isNotEmpty) ...[
                  Text(
                    'Code will be sent to: ${_hints[0]}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                if (_verificationId == null)
                  MyButton(
                    onTap: _loading ? null : _sendCode,
                    text: _loading ? 'Sending...' : 'Send Code',
                  )
                else
                  Column(
                    children: [
                      MyTextfield(
                        controller: _codeController,
                        hintText: 'Enter 6-digit code',
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
          );
        },
      ),
    );
  }

  Future<void> _sendCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await context.read<AuthCubit>().sendLoginCode(
      _selectedHintIndex,
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

    await context.read<AuthCubit>().verifyMFA(
      _codeController.text,
      _verificationId!,
      _selectedHintIndex,
    );
  }

  void _resend() {
    setState(() {
      _verificationId = null;
      _codeController.clear();
      _error = null;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
