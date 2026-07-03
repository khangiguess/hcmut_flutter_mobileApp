import 'package:flutter/material.dart';

class breathPage extends StatelessWidget {
  const breathPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breath Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Breath Page!'),
      ),
    );
  }
} 