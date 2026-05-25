import '../../utils/app_fonts.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../screens/home/home_screen.dart';
import 'login_screen.dart';
import '../../services/app_initializer.dart';
import '../../services/data_sync_service.dart';

// ─── Color palette (tweak to match your kPrimaryColor / kSecondaryColor) ────
const Color _deep = Color(0xFF1B4332);
const Color _mid = Color(0xFF2D6A4F);
const Color _accent = Color(0xFF74C69D);
const Color _gold = Color(0xFFFFE082);

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navTimer;
  late final Future<void> _initFuture;

  // Logo ring
  late AnimationController _ringCtrl;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;

  // Text fade/slide
  late AnimationController _textCtrl;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // Ambient wheat sway
  late AnimationController _swayCtrl;

  // Scan-line shimmer
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();

    _initFuture = AppInitializer.ensureInitialized();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      FlutterNativeSplash.remove();
    });

    // ── Ring pop ──────────────────────────────────────────────
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ringScale = CurvedAnimation(parent: _ringCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _ringOpacity = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    // ── Text reveal ───────────────────────────────────────────
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _textSlide = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.35), end: Offset.zero));

    // ── Wheat sway (loops) ────────────────────────────────────
    _swayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // ── Shimmer (loops) ───────────────────────────────────────
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // ── Sequence ──────────────────────────────────────────────
    _ringCtrl.forward().then((_) {
      _textCtrl.forward();
    });

    _navigate();
  }

  Future<void> _navigate() async {
    await _initFuture;
    
    // Check if data needs sync
    final bool isStale = await DataSyncService.isDataStale();
    if (isStale) {
      // Simulate data fetch from Firebase (using dummy data, so just a delay)
      await Future.delayed(const Duration(milliseconds: 1500));
      await DataSyncService.markSynced();
    } else {
      // Small delay for smooth animation if no sync needed
      await Future.delayed(const Duration(milliseconds: 2000));
    }
    
    if (!mounted) return;
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    Navigator.pushReplacement<void, void>(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
            loggedIn ? const HomeScreen() : const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        settings: RouteSettings(
          name: loggedIn ? HomeScreen.routeName : LoginScreen.routeName,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _ringCtrl.dispose();
    _textCtrl.dispose();
    _swayCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. Rich gradient background ──────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_deep, _mid, Color(0xFF40916C)],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── 2. Top-right radial orb ───────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accent.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Bottom-left radial orb ─────────────────────────
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _deep.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 4. Animated scan-line shimmer ─────────────────────
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _ScanLinePainter(_shimmerCtrl.value),
            ),
          ),

          // ── 5. Animated wheat field (bottom) ──────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.38,
            child: AnimatedBuilder(
              animation: _swayCtrl,
              builder: (_, __) => CustomPaint(
                painter: _WheatFieldPainter(_swayCtrl.value),
              ),
            ),
          ),

          // ── 6. Horizon golden glow ────────────────────────────
          Positioned(
            bottom: size.height * 0.28,
            left: -40,
            right: -40,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _gold.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 7. Main content ───────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 5),

                  // Logo ring
                  AnimatedBuilder(
                    animation: _ringCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _ringOpacity.value,
                      child: Transform.scale(
                        scale: _ringScale.value,
                        child: const _LogoRing(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name + tagline
                  FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Agri',
                                  style: AppFonts.playfairDisplay(context, 
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Pulse',
                                  style: AppFonts.playfairDisplay(context, 
                                    color: _accent,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'MARKET INTELLIGENCE',
                            style: AppFonts.dmSans(context, 
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 4.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 40,
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          const SizedBox(height: 20),
                          // (badges removed)
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 6),

                  // Loading indicator
                  FadeTransition(
                    opacity: _textOpacity,
                    child: _PulseIndicator(color: _accent),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo Ring ──────────────────────────────────────────────────────────────

class _LogoRing extends StatelessWidget {
  const _LogoRing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer dashed ring
          CustomPaint(painter: _DashedCirclePainter()),
          // Inner frosted circle
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // Emoji
          const Text('🌾', style: TextStyle(fontSize: 44)),
        ],
      ),
    );
  }
}

// ── Dashed circle painter ───────────────────────────────────────────────────

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const int dashCount = 24;
    const double dashAngle = (2 * math.pi) / dashCount;
    const double gapFraction = 0.45;
    final double r = size.width / 2;
    final Offset center = Offset(r, r);

    for (int i = 0; i < dashCount; i++) {
      final double start = i * dashAngle;
      final double sweep = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r - 1),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Wheat Field Painter ─────────────────────────────────────────────────────

class _WheatFieldPainter extends CustomPainter {
  final double sway; // 0..1, reversed for breeze effect
  const _WheatFieldPainter(this.sway);

  @override
  void paint(Canvas canvas, Size size) {
    // Dark rolling hills
    final Paint hillPaint = Paint()..style = PaintingStyle.fill;

    hillPaint.color = const Color(0xFF1B4332).withValues(alpha: 0.75);
    final Path hill1 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.35,
          size.width * 0.55, size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.8, size.height * 0.78,
          size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hill1, hillPaint);

    hillPaint.color = const Color(0xFF163A28).withValues(alpha: 0.9);
    final Path hill2 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width * 0.3, size.height * 0.55,
          size.width * 0.6, size.height * 0.72)
      ..quadraticBezierTo(
          size.width * 0.85, size.height * 0.85,
          size.width, size.height * 0.62)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hill2, hillPaint);

    // Wheat stalks
    final double swayOffset = (sway - 0.5) * 12.0;
    final Paint stalkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const int columns = 14;
    for (int i = 0; i < columns; i++) {
      final double x = (size.width / (columns - 1)) * i;
      final double heightFactor = 0.55 + (i % 3) * 0.08;
      final double baseY = size.height;
      final double tipY = size.height * (1 - heightFactor);
      final double phase = (i % 4) / 4.0;
      final double sO = swayOffset * (1 + phase * 0.5);

      stalkPaint
        ..color = const Color(0xFF52B788).withValues(alpha: 0.45)
        ..strokeWidth = 1.0;

      final Path stalk = Path()
        ..moveTo(x, baseY)
        ..quadraticBezierTo(x + sO * 0.5, (baseY + tipY) / 2, x + sO, tipY);
      canvas.drawPath(stalk, stalkPaint);

      // Wheat head (simple lines)
      stalkPaint
        ..color = const Color(0xFF74C69D).withValues(alpha: 0.5)
        ..strokeWidth = 1.2;

      final double hx = x + sO;
      final double hy = tipY;
      canvas.drawLine(Offset(hx, hy), Offset(hx - 5, hy - 10), stalkPaint);
      canvas.drawLine(Offset(hx, hy), Offset(hx + 5, hy - 10), stalkPaint);
      canvas.drawLine(Offset(hx, hy - 4), Offset(hx - 4, hy - 13), stalkPaint);
      canvas.drawLine(Offset(hx, hy - 4), Offset(hx + 4, hy - 13), stalkPaint);
    }

    // Floating light particles
    final Paint dotPaint = Paint()
      ..color = const Color(0xFF74C69D).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final List<Offset> dots = [
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.40, size.height * 0.18),
      Offset(size.width * 0.65, size.height * 0.22),
      Offset(size.width * 0.85, size.height * 0.30),
    ];
    for (final Offset dot in dots) {
      canvas.drawCircle(dot, 1.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WheatFieldPainter old) => old.sway != sway;
}

// ── Scan-line shimmer painter ───────────────────────────────────────────────

class _ScanLinePainter extends CustomPainter {
  final double progress;
  const _ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Offset.zero & size);

    final double y = size.height * progress;
    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), p);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter old) => old.progress != progress;
}


// ── Subtle pulsing loader ───────────────────────────────────────────────────

class _PulseIndicator extends StatefulWidget {
  final Color color;
  const _PulseIndicator({required this.color});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 0.3, end: 1.0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == 0 ? 18 : 6,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: widget.color
                  .withValues(alpha: _anim.value * (i == 0 ? 1.0 : 0.4)),
            ),
          );
        }),
      ),
    );
  }
}
