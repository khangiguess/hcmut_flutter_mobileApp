import 'package:flutter/material.dart';

class quizPage extends StatelessWidget {
  const quizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Quiz Page!'),
      ),
    );
  }
}