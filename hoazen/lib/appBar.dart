import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pages/home/flower.dart';
import 'pages/journal/calendar.dart';
import 'pages/breath.dart';

void main() {
  runApp(const HoaZenApp());
}

class HoaZenApp extends StatelessWidget {
  const HoaZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HoaZen',
      debugShowCheckedModeBanner: false,
      home: BottomNavigationBarExample(),
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

  String _resolveFirstName(User? user) {
    if (user == null) {
      return 'User';
    }

    final displayName = user.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) {
      return displayName.split(RegExp(r'\s+')).first;
    }

    final email = user.email?.trim() ?? '';
    if (email.contains('@')) {
      return email.split('@').first;
    }

    return 'User';
  }

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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      
      appBar: AppBar(
        toolbarHeight: 140, // Height increased to give spacing for text and dots
        automaticallyImplyLeading: false, // Prevents accidental back arrows
        flexibleSpace: ClipRect(
          child: Stack(
            children: [
              // 1. Background Gradient Layer
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF42624B), Color(0xFFAAC29E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              
              // 2. Greeting Text (shown only on Home tab)
              if (_selectedIndex == 0)
                Positioned(
                  bottom: 20, // Lowers the text closer to the white body card
                  left: 20,   // Side margins
                  child: Text(
                    'Hello, ${_resolveFirstName(FirebaseAuth.instance.currentUser)}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 28,
                      fontFamily: 'Serif',
                    ),
                  ),
                ),
              
              // 3. --- SCATTERED BUBBLES/DOTS MAP ---
              
              // Top Left small dot
              Positioned(
                top: 25,
                left: 130,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF2B2).withOpacity(0.15)),
                ),
              ),
              
              // Top Center medium dot
              Positioned(
                top: 15,
                left: 180,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF2B2).withOpacity(0.15)),
                ),
              ),

              Positioned(
                top: 40,
                left: 280,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF2B2).withOpacity(0.15)),
                ),
              ),

              Positioned(
                top: 50,
                left: 220,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF2B2).withOpacity(0.15)),
                ),
              ),

              // Mid Left small dot (near the text)
              Positioned(
                top: 60,
                left: 140,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF2B2).withOpacity(0.15)),
                ),
              ),

              // Top Right far small dot
              Positioned(
                top: 20,
                right: 40,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF2B2).withOpacity(0.15)),
                ),
              ),

              // Mid Right prominent medium dot
              Positioned(
                top: 65,
                right: 100,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF2B2).withOpacity(0.15)),
                ),
              ),

              // Bottom Right large dot (lowest one)
              Positioned(
                bottom: 15,
                right: 25,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF2B2).withOpacity(0.15)),
                ),
              ),

              // Far Bottom Right cut-off dot
              Positioned(
                bottom: 5,
                right: 75,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF2B2).withOpacity(0.15)),
                ),
              ),
            ],
          ),
        ),
      ),

      // Fades and slides gently between tabs instead of switching instantly.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF42624B), Color(0xFFAAC29E)],
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
      ),
    );
  }
}
