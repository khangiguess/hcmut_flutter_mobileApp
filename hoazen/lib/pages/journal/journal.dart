import 'package:flutter/material.dart';

class journalPage extends StatelessWidget {
  const journalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Journal Page!'),
      ),
    );
  }
}