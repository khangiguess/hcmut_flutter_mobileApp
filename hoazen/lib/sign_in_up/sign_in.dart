import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoazen/sign_in_up/sign_up.dart';
import 'auth_service.dart';
import 'package:hoazen/appBar.dart';
import 'package:hoazen/shared/checkin_common.dart';


// Global constants for the sign-in screen.
const iconImage = 'assets/hoazen.png';
const _primaryColor = Color(0xFF42624B);
const _secondaryColor = Color(0xFFAAC29E);
const _borderColor = Color(0xFFEF91A3);
const _hintColor = Color(0xFF8D8D8D);
const _textColor = Color(0xFF22333B);

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Controllers to read the text input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Loading state for the button
  bool _isLoading = false;

  // Firebase Sign In Logic utilizing your AuthService
  Future<void> _signIn() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      

      if (FirebaseAuth.instance.currentUser != null) {
        // Replaces the login screen with a smooth fade/slide into the home screen.
        Navigator.pushReplacement(
          context,
          FadeSlideRoute(page: const HoaZenApp()),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48, 
                  maxWidth: 390,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: Image.asset(
                          iconImage,
                          fit: BoxFit.contain,
                          height: 120, 
                          width: 160,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.eco_outlined,
                              size: 100,
                              color: _borderColor,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Sign In',
                        style: GoogleFonts.lora(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 42, 
                          height: 1.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF252525),
                        ),
                      ),  
                      const SizedBox(height: 4),
                      Text(
                        'to bloom care towards you',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 48),

                      _AuthInput(
                        controller: _emailController,
                        hintText: 'Enter your email',
                        suffixIcon: const Icon(Icons.email_outlined, color: _hintColor),
                        obscureText: false,
                        backgroundColor: const Color(0xFFFCF8F9), 
                      ),

                      const SizedBox(height: 16),

                      _AuthInput(
                        controller: _passwordController,
                        hintText: 'Password',
                        suffixIcon: const Icon(Icons.visibility_off_outlined, color: _hintColor),
                        obscureText: true,
                        backgroundColor: const Color(0xFFF5F5F5), 
                      ),

                      const Spacer(), 

                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [_primaryColor, _secondaryColor],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _textColor,
                          padding: EdgeInsets.zero,
                        ),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                            children: [
                              TextSpan(text: 'New member ', style: TextStyle(color: _hintColor)),
                              TextSpan(text: '?', style: TextStyle(color: _hintColor)),
                              TextSpan(text: ' ', style: TextStyle(color: _hintColor)),
                              TextSpan(
                                text: 'Register now', 
                                style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthInput extends StatefulWidget {
  const _AuthInput({
    required this.hintText,
    this.suffixIcon,
    this.obscureText = false,
    required this.backgroundColor,
    this.controller,
  });

  final String hintText;
  final Widget? suffixIcon;
  final bool obscureText;
  final Color backgroundColor;
  final TextEditingController? controller;

  @override
  State<_AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<_AuthInput> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    Widget? activeSuffixIcon = widget.suffixIcon;
    
    if (widget.obscureText) {
      activeSuffixIcon = IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: _hintColor,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
        splashRadius: 24, 
      );
    }

    return TextField(
      controller: widget.controller,
      obscureText: _isObscured,
      style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFFC4C4C4), 
          fontSize: 14,
        ),
        filled: true,
        fillColor: widget.backgroundColor, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: activeSuffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF91A3), width: 1.5),
        ),
      ),
    );
  }
}