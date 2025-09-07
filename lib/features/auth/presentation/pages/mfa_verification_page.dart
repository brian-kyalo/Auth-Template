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
  int? _selectedIndex;
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MFA Verification')),
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
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is! MFAVerificationRequired)
              return const SizedBox.shrink();
            final hints = state.hints;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text('Select Phone', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  if (_verificationId == null)
                    Column(
                      children: [
                        ...hints.asMap().entries.map(
                          (e) => RadioListTile<int>(
                            value: e.key,
                            groupValue: _selectedIndex,
                            title: Text(
                              '****${e.value.substring(e.value.length - 4)}',
                            ),
                            onChanged: (idx) =>
                                setState(() => _selectedIndex = idx),
                          ),
                        ),
                        const SizedBox(height: 16),
                        MyButton(
                          onTap: _selectedIndex == null || _loading
                              ? null
                              : _sendCode,
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
            );
          },
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    setState(() => _loading = true);
    await context.read<AuthCubit>().sendLoginCode(
      _selectedIndex!,
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
    if (_codeController.text.length != 6 ||
        _verificationId == null ||
        _selectedIndex == null) {
      setState(() => _error = 'Invalid code');
      return;
    }
    setState(() => _loading = true);
    await context.read<AuthCubit>().verifyMFA(
      _codeController.text,
      _verificationId!,
      _selectedIndex!,
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
    _codeController.dispose();
    super.dispose();
  }
}
