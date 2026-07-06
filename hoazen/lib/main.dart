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
        title: const Text('Hoazen'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF42624B), const Color(0xFFAAC29E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),



      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF42624B), const Color(0xFFAAC29E)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFFFF2B2),
          unselectedItemColor: const Color(0xFFBBC293),
          onTap: _onItemTapped,

          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.air), label: ''),
          ],
        ),
      )
    );
  }
}
