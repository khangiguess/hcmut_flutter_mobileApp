import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hoazen/sign_in_up/sign_in.dart';
import 'package:hoazen/sign_in_up/auth_service.dart';

// Global constants for the sign-up screen.
const iconImage = 'assets/hoazen.png';
const _primaryColor = Color(0xFF42624B);
const _secondaryColor = Color(0xFFAAC29E);
const _borderColor = Color(0xFFEF91A3);
const _hintColor = Color(0xFF8D8D8D);
const _textColor = Color(0xFF22333B);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    this.onSignUpSuccess,
  });

  final VoidCallback? onSignUpSuccess;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isTermsChecked = false;


  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );

      if (widget.onSignUpSuccess != null) {
        widget.onSignUpSuccess!();
        return;
      }

      // Return to the root route; AppEntryGate will route to onboarding/home.
      if (!mounted) {
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // dispose of controllers when screen closes
  @override
  void dispose() {
    _nameController.dispose();
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
                        'Sign Up',
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
                        controller: _nameController,
                        hintText: 'Username',
                        suffixIcon: const Icon(Icons.person_outline, color: _hintColor),
                        obscureText: false,
                        backgroundColor: const Color(0xFFFCF8F9), 
                      ),

                      const SizedBox(height: 16),

                      _AuthInput(
                        controller: _emailController,
                        hintText: 'Valid email',
                        suffixIcon: const Icon(Icons.email_outlined, color: _hintColor),
                        obscureText: false,
                        backgroundColor: const Color(0xFFF5F5F5),
                      ),

                      const SizedBox(height: 16),

                      _AuthInput(
                        controller: _passwordController,
                        hintText: 'Strong password',
                        suffixIcon: const Icon(Icons.visibility_off_outlined, color: _hintColor),
                        obscureText: true,
                        backgroundColor: const Color(0xFFF5F5F5),
                      ),

                      const SizedBox(height: 32),

                      _TermsCheckbox(
                        isChecked: _isTermsChecked,
                        onChanged: (value) {
                          setState(() {
                            _isTermsChecked = value ?? false;
                          });
                        },
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
                            onPressed: (_isLoading || !_isTermsChecked) ? null : _signUp,
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
                            // 8. Show a tiny loading spinner if currently processing
                            child: _isLoading 
                              ? const SizedBox(
                                  height: 24, 
                                  width: 24, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
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
                            MaterialPageRoute(builder: (context) => const SignInScreen()),
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
                              TextSpan(text: 'Already a member', style: TextStyle(color: _hintColor)),
                              TextSpan(text: '?', style: TextStyle(color: _hintColor)),
                              TextSpan(text: ' ', style: TextStyle(color: _hintColor)),
                              TextSpan(
                                text: 'Login in', 
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
      controller: widget.controller, // 11. Passed the controller into the actual TextField
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


class _TermsCheckbox extends StatelessWidget {
  final bool isChecked;
  
  final ValueChanged<bool?> onChanged; 

  const _TermsCheckbox({
    Key? key,
    required this.isChecked,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: isChecked, // Reads the value passed down from the screen
            activeColor: _primaryColor,
            side: const BorderSide(color: _hintColor, width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: onChanged, // Passes the tap event back up to the screen
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: _hintColor,
                height: 1.4,
              ),
              children: [
                TextSpan(text: 'By checking the box you agree to our '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}