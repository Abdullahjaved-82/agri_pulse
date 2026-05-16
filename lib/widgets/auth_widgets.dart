import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _deep        = Color(0xFF1B4332);
const Color _mid         = Color(0xFF2D6A4F);
const Color _bright      = Color(0xFF40916C);
const Color _fieldBg     = Color(0xFFF6FBF8);
const Color _fieldBorder = Color(0xFFD4E8DB);

// ─── Wave header ────────────────────────────────────────────────────────────

class _WaveHeader extends StatelessWidget {
  final String title;
  const _WaveHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195,
      width: double.infinity,
      child: Stack(
        children: [
          // Gradient bg
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B4332), Color(0xFF40916C)],
              ),
            ),
          ),
          // Subtle top-right orb
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // Wave at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(height: 40, color: Colors.white),
            ),
          ),
          // Content — sits above the wave
          Positioned.fill(
            bottom: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dashed ring + logo
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(80, 80),
                        painter: _DashedRingPainter(),
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Text('🌾', style: TextStyle(fontSize: 30)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'AGRIPULSE',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 9,
                    letterSpacing: 3.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, size.height)
    ..quadraticBezierTo(
        size.width * 0.30, 0, size.width * 0.55, size.height * 0.65)
    ..quadraticBezierTo(
        size.width * 0.78, size.height * 1.15, size.width, size.height * 0.35)
    ..lineTo(size.width, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> _) => false;
}

class _DashedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const int count = 20;
    final double r = size.width / 2 - 1;
    final Offset c = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < count; i++) {
      final double start = i * (2 * math.pi / count);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        (2 * math.pi / count) * 0.55,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Text field ─────────────────────────────────────────────────────────────

class _AgriField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? errorText;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const _AgriField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.onToggleObscure,
    this.errorText,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLength: maxLength,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400, fontSize: 14),
        counterText: '',
        errorText: errorText,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        prefixIcon: Icon(icon, color: _bright, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
          onPressed: onToggleObscure,
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _bright, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Dropdown (role) ─────────────────────────────────────────────────────────

class _AgriDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _AgriDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'I am a...',
        hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        prefixIcon: const Icon(Icons.agriculture_outlined, color: _bright, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _bright, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'Farmer', child: Text('Farmer')),
        DropdownMenuItem(value: 'Trader', child: Text('Trader')),
        DropdownMenuItem(value: 'Both',   child: Text('Both')),
      ],
    );
  }
}

// ─── Primary button ──────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _deep,
          disabledBackgroundColor: _mid.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ─── Footer row ──────────────────────────────────────────────────────────────

class _FooterRow extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback? onTap;

  const _FooterRow({
    required this.question,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: Colors.grey.shade500)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _bright,
            ),
          ),
        ),
      ],
    );
  }
}