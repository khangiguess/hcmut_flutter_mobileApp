import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:hoazen/sign_in_up/sign_in.dart';
import 'package:hoazen/sign_in_up/wait_screen.dart';
import 'appBar.dart';

void main() async {
  // Required to ensure the Flutter engine is ready before Firebase starts
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hoa Zen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Updated the seed color to match your app's primary green theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF42624B),
        ),
        useMaterial3: true,
      ),

      home: const AppEntryGate(),
    );
  }
}

class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  static const _splashDuration = Duration(milliseconds: 2500);
  bool _isSplashDone = false;

  @override
  void initState() {
    super.initState();
    Timer(_splashDuration, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSplashDone = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSplashDone) {
      return const WaitScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const WaitScreen();
        }

        if (snapshot.data == null) {
          return const SignInScreen();
        }

        return const BottomNavigationBarExample();
      },
    );
  }
}