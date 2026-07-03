import 'package:flutter/material.dart';

class FlowerPage extends StatelessWidget {
  const FlowerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flower Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Flower Page!'),
      ),
    );
  }
}