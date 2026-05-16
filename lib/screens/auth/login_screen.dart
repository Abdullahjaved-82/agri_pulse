import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agri_pulse/screens/home/home_screen.dart';
import 'package:agri_pulse/utils/colors.dart';
import 'package:agri_pulse/utils/constants.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../utils/language_provider.dart';
import 'signup_screen.dart';

const Color _deep        = Color(0xFF1B4332);
const Color _bright      = Color(0xFF40916C);
const Color _fieldBg     = Color(0xFFF6FBF8);
const Color _fieldBorder = Color(0xFFD4E8DB);

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final String email    = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Enter email and password to continue.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signIn(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } catch (error) {
      if (mounted) _showSnack(_authService.readableError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final bool isUrdu = LanguageScope.of(context).isUrdu;
    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header — never pushed by keyboard
            _WaveHeader(title: isUrdu ? 'خوش آمدید!' : 'Welcome Back!'),

            // Scrollable form — handles keyboard inset safely
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrdu ? 'ایگری پلس میں لاگ ان کریں' : 'Login to AgriPulse',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: _deep,
                      ),
                    ),
                    const SizedBox(height: 22),

                    _AgriField(
                      controller: _emailController,
                      hint: isUrdu ? 'ای میل ایڈریس' : 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _AgriField(
                      controller: _passwordController,
                      hint: isUrdu ? 'پاس ورڈ' : 'Password',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushNamed(
                            context, MyApp.forgotPasswordRoute),
                        style: TextButton.styleFrom(
                          foregroundColor: _bright,
                          padding: const EdgeInsets.only(top: 2, bottom: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          isUrdu ? 'پاس ورڈ بھول گئے؟' : 'Forgot Password?',
                          style: GoogleFonts.dmSans(fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),
                    _PrimaryButton(
                      label: isUrdu ? 'لاگ ان کریں' : 'Login',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 20),

                    _FooterRow(
                      question: isUrdu ? "اکاؤنٹ نہیں ہے؟" : "Don't have an account?",
                      action: isUrdu ? 'سائن اپ کریں' : 'Sign Up',
                      onTap: _isLoading
                          ? null
                          : () => Navigator.pushNamed(
                          context, SignupScreen.routeName),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveHeader extends StatelessWidget {
  final String title;

  const _WaveHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor, kSecondaryColor],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.elliptical(600, 110),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌾', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgriField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  const _AgriField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _fieldBg,
        prefixIcon: Icon(icon, color: _bright),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: _bright,
                ),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: const BorderSide(color: _fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: const BorderSide(color: _fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: const BorderSide(color: kSecondaryColor, width: 1.4),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback? onTap;

  const _FooterRow({
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question, style: GoogleFonts.dmSans(fontSize: 13)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: _bright),
          child: Text(action, style: GoogleFonts.dmSans(fontSize: 13)),
        ),
      ],
    );
  }
}

