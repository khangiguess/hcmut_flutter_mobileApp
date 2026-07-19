import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hoazen/onboarding/onboarding_page.dart';
import 'package:hoazen/sign_in_up/sign_up.dart';
import 'package:hoazen/sign_in_up/sign_in.dart';
import 'package:hoazen/sign_in_up/wait_screen.dart';
import 'package:hoazen/shared/checkin_common.dart';
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
  _AppFlowStep _step = _AppFlowStep.splash;

  @override
  void initState() {
    super.initState();
    Timer(_splashDuration, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _step = _AppFlowStep.auth;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fades and slides gently between app flow steps (splash → auth → onboarding → home).
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(_step),
        child: _buildStep(context),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _AppFlowStep.splash:
        return const WaitScreen();
      case _AppFlowStep.auth:
        return SignInScreen(
          onSignInSuccess: () {
            if (!mounted) {
              return;
            }

            setState(() {
              _step = _AppFlowStep.home;
            });
          },
          onCreateAccountTap: () {
            Navigator.of(context).push(
              FadeSlideRoute(
                page: SignUpScreen(
                  onSignUpSuccess: () {
                    if (!mounted) {
                      return;
                    }

                    Navigator.of(context).pop();
                    setState(() {
                      _step = _AppFlowStep.onboarding;
                    });
                  },
                ),
              ),
            );
          },
        );
      case _AppFlowStep.onboarding:
        return OnboardingPage(
          onFinish: () {
            if (!mounted) {
              return;
            }

            setState(() {
              _step = _AppFlowStep.home;
            });
          },
        );
      case _AppFlowStep.home:
        return BottomNavigationBarExample(
          onLogoutSuccess: () {
            if (!mounted) {
              return;
            }

            setState(() {
              _step = _AppFlowStep.auth;
            });
          },
        );
    }
  }
}

enum _AppFlowStep {
  splash,
  auth,
  onboarding,
  home,
}
