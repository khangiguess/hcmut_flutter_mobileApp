import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/home/flower.dart';
import 'pages/home/quiz.dart';
import 'pages/journal/calendar.dart';
import 'pages/journal/journal.dart';
import 'pages/breath.dart';


void main() {
  runApp(const HoaZenApp());
}

class HoaZenApp extends StatelessWidget {
  const HoaZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HoaZen',
      debugShowCheckedModeBanner: false,
      home: BottomNavigationBarExample()
    );
  }
}
class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FlowerPage(),
    const calendarPage(),
    const breathPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoa Zen'),
        //backgroundColor: const Color.fromRGBO(155, 44, 50, 1),
        //foregroundColor: Colors.white,
      ),


      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(155, 44, 50, 1), Color.fromRGBO(184, 160, 129, 1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.air), label: 'Breath'),
        ],
      ),
      )
    );
  }
}