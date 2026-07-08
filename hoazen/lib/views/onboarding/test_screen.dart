import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Global constants for the sign-in screen.
const iconImage = 'assets/hoazen.png';
const _primaryColor = Color(0xFF42624B);
const _secondaryColor = Color(0xFFAAC29E);
const _borderColor = Color(0xFFEF91A3);
const _hintColor = Color(0xFF8D8D8D);
const _textColor = Color(0xFF22333B);

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

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
                          height: 200, 
                          width: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.eco_outlined,
                              size: 100,
                              color: _borderColor,
                            );
                          },
                        ),
                      ),


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

                      // 1. Email input (Faint pink background)
                      const _AuthInput(
                        hintText: 'Enter your email',
                        suffixIcon: Icon(Icons.email_outlined, color: _hintColor),
                        obscureText: false,
                        backgroundColor: Color(0xFFFCF8F9), 
                      ),

                      const SizedBox(height: 16),

                      // 2. Password input (Light grey background)
                      const _AuthInput(
                        hintText: 'Password',
                        suffixIcon: Icon(Icons.visibility_off_outlined, color: _hintColor),
                        obscureText: true,
                        backgroundColor: Color(0xFFF5F5F5), 
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
                            child: const Row(
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

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.hintText,
    this.suffixIcon,
    this.obscureText = false,
    required this.backgroundColor, 
  });

  final String hintText;
  final Widget? suffixIcon;
  final bool obscureText;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: const Color(0xFFC4C4C4), // Adjusted slightly so it's readable 
          fontSize: 14,
        ),
        
        filled: true,
        fillColor: backgroundColor, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: suffixIcon,

        // 1. The BASE border (forces Flutter to remove default underlines/borders entirely)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),

        // 2. The border when NOT selected (forces it to be completely invisible)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),

        // 3. The border when IS selected (Shows your beautiful pink outline!)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF91A3), width: 1.5),
        ),
      ),
    );
  }
}