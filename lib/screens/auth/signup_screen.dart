import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agri_pulse/utils/colors.dart';
import 'package:agri_pulse/utils/constants.dart';
import '../../services/auth_service.dart';
import '../../utils/language_provider.dart';

const Color _deep        = Color(0xFF1B4332);
const Color _mid         = Color(0xFF2D6A4F);
const Color _bright      = Color(0xFF40916C);
const Color _fieldBg     = Color(0xFFF6FBF8);
const Color _fieldBorder = Color(0xFFD4E8DB);

class SignupScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole         = 'Farmer';
  bool _isLoading              = false;
  String? _confirmPasswordError;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController    = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController  = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final String fullName = _fullNameController.text.trim();
    final String phone    = _phoneController.text.trim();
    final String email    = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirm  = _confirmController.text.trim();

    if (fullName.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack('Please fill in all required fields.');
      return;
    }
    if (phone.length != 11 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showSnack('Please enter a valid 11-digit phone number.');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnack('Please enter a valid email format.');
      return;
    }
    if (password.length < 8) {
      _showSnack('Password must be at least 8 characters.');
      return;
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~])')
        .hasMatch(password)) {
      _showSnack(
          'Password must include uppercase, lowercase, a number, and a special character.');
      return;
    }
    if (password != confirm) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      return;
    } else {
      setState(() => _confirmPasswordError = null);
    }

    setState(() => _isLoading = true);
    try {
      await _authService
          .signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: _selectedRole,
      )
          .timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException(
            'Signup is taking too long. Please try again.'),
      );

      if (!mounted) return;
      await _authService.signOut();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Account created successfully! Please login.'),
        backgroundColor: Color(0xFF2D6A4F),
      ));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      if (mounted) {
        final String msg = error is TimeoutException
            ? (error.message ?? 'Signup timed out. Please retry.')
            : _authService.readableError(error);
        _showSnack(msg);
      }
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
            _WaveHeader(title: isUrdu ? 'ایگری پلس میں شامل ہوں' : 'Join AgriPulse'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrdu ? 'اپنا اکاؤنٹ بنائیں' : 'Create your account',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: _deep,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _AgriField(
                      controller: _fullNameController,
                      hint: isUrdu ? 'پورا نام' : 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _AgriField(
                      controller: _phoneController,
                      hint: isUrdu ? 'فون نمبر (11 ہندسے)' : 'Phone Number (11 digits)',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                    ),
                    const SizedBox(height: 12),
                    _AgriField(
                      controller: _emailController,
                      hint: isUrdu ? 'ای میل ایڈریس' : 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _AgriField(
                      controller: _passwordController,
                      hint: isUrdu ? 'پاس ورڈ' : 'Password',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 12),
                    _AgriField(
                      controller: _confirmController,
                      hint: isUrdu ? 'پاس ورڈ کی تصدیق کریں' : 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscure: _obscureConfirmPassword,
                      onToggleObscure: () => setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword),
                      errorText: _confirmPasswordError != null ? (isUrdu ? 'پاس ورڈ مماثل نہیں ہیں' : _confirmPasswordError) : null,
                      onChanged: (_) {
                        if (_confirmPasswordError != null) {
                          setState(() => _confirmPasswordError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Role dropdown
                    _AgriDropdown(
                      value: _selectedRole,
                      isUrdu: isUrdu,
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedRole = v);
                      },
                    ),
                    const SizedBox(height: 20),

                    _PrimaryButton(
                      label: isUrdu ? 'سائن اپ کریں' : 'Sign Up',
                      isLoading: _isLoading,
                      onPressed: _handleSignup,
                    ),
                    const SizedBox(height: 16),

                    _FooterRow(
                      question: isUrdu ? 'پہلے سے ہی اکاؤنٹ ہے؟' : 'Already have an account?',
                      action: isUrdu ? 'لاگ ان کریں' : 'Login',
                      onTap: _isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                          context, '/login'),
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
  final int? maxLength;
  final bool obscure;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onToggleObscure;

  const _AgriField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLength,
    this.obscure = false,
    this.errorText,
    this.onChanged,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        counterText: maxLength == null ? null : '',
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
        errorText: errorText,
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

class _AgriDropdown extends StatelessWidget {
  final String value;
  final bool isUrdu;
  final ValueChanged<String?>? onChanged;

  const _AgriDropdown({required this.value, required this.isUrdu, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: isUrdu ? 'میں ہوں...' : 'I am a...',
        filled: true,
        fillColor: _fieldBg,
        prefixIcon: const Icon(Icons.agriculture_outlined, color: _bright),
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
      items: [
        DropdownMenuItem(value: 'Farmer', child: Text(isUrdu ? 'کسان (Farmer)' : 'Farmer')),
        DropdownMenuItem(value: 'Trader', child: Text(isUrdu ? 'تاجر (Trader)' : 'Trader')),
        DropdownMenuItem(value: 'Both', child: Text(isUrdu ? 'دونوں' : 'Both')),
      ],
      onChanged: onChanged,
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

