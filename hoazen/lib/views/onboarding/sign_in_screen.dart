import 'package:flutter/material.dart';

// Global constants for the sign-in screen.
const iconImage = 'assets/hoazen.png';
const _primaryColor = Color(0xFF42624B);
const _secondaryColor = Color(0xFFAAC29E);
const _borderColor = Color(0xFFEF91A3);
const _hintColor = Color(0xFF8D8D8D);
const _textColor = Color(0xFF22333B);

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Icon image placed at the top of the screen.
                  SizedBox(
                    height: 220,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          iconImage,
                          fit: BoxFit.contain,
                          height: 180,
                          width: 180,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.eco_outlined,
                              size: 140,
                              color: _primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Title and supporting copy for the sign-in section.
                  Column(
                    children: [
                      Text(
                        'Sign In',
                        style: textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF252525),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'to bloom care towards you',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Email input field with an outlined container and icon.
                  _AuthInput(
                    hintText: 'Enter your email',
                    suffixIcon: const Icon(Icons.email_outlined, color: _hintColor),
                    obscureText: false,
                  ),

                  const SizedBox(height: 16),

                  // Password input field with the eye toggle style.
                  _AuthInput(
                    hintText: 'Password',
                    suffixIcon: const Icon(Icons.visibility_off_outlined, color: _hintColor),
                    obscureText: true,
                  ),

                  const SizedBox(height: 48),

                  // Primary action button to continue the sign-in flow.
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Registration prompt for new users.
                  TextButton(
                    onPressed: () {},
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
                          TextSpan(text: 'Register now', style: TextStyle(color: _textColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.hintText,
    required this.suffixIcon,
    this.obscureText = false,
  });

  final String hintText;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x33C4C4C4),
        border: Border.all(color: _borderColor.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: _hintColor,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}