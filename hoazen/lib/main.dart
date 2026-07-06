import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hoazen/views/onboarding/sign_in_screen.dart';
import 'firebase_options.dart';

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
      // This tells the app to load your SignInScreen first!
      home: const SignInScreen(),
    );
  }
}