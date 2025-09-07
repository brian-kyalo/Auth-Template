import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter/features/auth/data/firebase_auth_repo.dart';
import 'package:starter/features/auth/presentation/components/loading.dart';
import 'package:starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:starter/features/auth/presentation/cubits/auth_state.dart';
import 'package:starter/features/auth/presentation/pages/auth_page.dart';
import 'package:starter/features/auth/presentation/pages/mfa_enrollment_page.dart';
import 'package:starter/features/auth/presentation/pages/mfa_verification_page.dart';
import 'package:starter/features/home/presentation/pages/home_page.dart';
import 'package:starter/firebase_options.dart';
import 'package:starter/themes/dark_mode.dart';
import 'package:starter/themes/light_mode.dart';

void main() async {
  //Firebase Setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //Auth repo.
  final firebaseAuthRepo = FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //auth cubit
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Learn Flutter & Firebase',
        theme: lightMode,
        darkTheme: darktMode,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            // ignore: avoid_print
            print(state);
            // unauthenticated -> auth page login/register
            //authenticated -> homepage
            //loading
            if (state is AuthLoading || state is Authinitial) {
              return const Center(child: Loading());
            }
            if (state is Unauthenticated) {
              return const AuthPage();
            }
            if (state is Authenticated) {
              return const HomePage();
            }
            if (state is MFARegistrationRequired) {
              return MfaEnrollmentPage(user: state.user);
            }
            if (state is MFAVerificationRequired) {
              return const MFAVerificationPage();
            }
            return const AuthPage();
          },
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),
    );
  }
}
