import '../../utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/language_provider.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const Color _deep   = Color(0xFF1B4332);
const Color _mid    = Color(0xFF2D6A4F);
const Color _accent = Color(0xFF74C69D);

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang   = LanguageScope.of(context);
    final isUrdu = lang.isUrdu;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ─────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 350,
            backgroundColor: _deep,
            foregroundColor: Colors.white,
            title: Text(
              isUrdu ? 'پروفائل' : 'My Profile',
              style: AppFonts.dmSans(context, fontWeight: FontWeight.w700),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHero(isUrdu: isUrdu),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Section: Account
                _SectionLabel(isUrdu ? 'اکاؤنٹ' : 'Account'),
                const SizedBox(height: 10),
                _PremiumTile(
                  icon: Icons.edit_rounded,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: _deep,
                  title: isUrdu ? 'پروفائل میں ترمیم' : 'Edit Profile',
                  subtitle: isUrdu ? 'نام، فون نمبر اپ ڈیٹ کریں' : 'Update name and phone',
                  onTap: () => _showSoonSnack(context, isUrdu ? 'پروفائل ترمیم' : 'Edit Profile'),
                ),
                _PremiumTile(
                  icon: Icons.notifications_rounded,
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFE65100),
                  title: isUrdu ? 'اطلاعات' : 'Notifications',
                  subtitle: isUrdu ? 'قیمت اور موسم کی اطلاعات' : 'Price and weather alerts',
                  onTap: () => Navigator.of(context).pushNamed(MyApp.notificationsRoute),
                ),

                const SizedBox(height: 20),

                // Section: Preferences
                _SectionLabel(isUrdu ? 'ترجیحات' : 'Preferences'),
                const SizedBox(height: 10),

                // Language Toggle
                _LanguagePremiumTile(lang: lang),

                const SizedBox(height: 20),

                // Section: Info
                _SectionLabel(isUrdu ? 'معلومات' : 'Information'),
                const SizedBox(height: 10),
                _PremiumTile(
                  icon: Icons.info_rounded,
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  title: isUrdu ? 'ایپ کے بارے میں' : 'About App',
                  subtitle: isUrdu ? 'ورژن، سپورٹ، رازداری' : 'Version, support, privacy',
                  onTap: () => Navigator.of(context).pushNamed(MyApp.aboutRoute),
                ),

                const SizedBox(height: 20),

                // Section: Account Actions
                _SectionLabel(isUrdu ? 'اکاؤنٹ' : 'Session'),
                const SizedBox(height: 10),
                _PremiumTile(
                  icon: Icons.logout_rounded,
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: Colors.red.shade700,
                  title: isUrdu ? 'لاگ آؤٹ' : 'Logout',
                  subtitle: isUrdu ? 'محفوظ طریقے سے باہر نکلیں' : 'Sign out from this device',
                  titleColor: Colors.red.shade700,
                  onTap: () => _showLogoutDialog(context, isUrdu),
                  showArrow: false,
                ),

                if (kDebugMode) ...[
                  const SizedBox(height: 10),
                  _PremiumTile(
                    icon: Icons.cloud_upload_rounded,
                    iconBg: const Color(0xFFF3E5F5),
                    iconColor: Colors.purple,
                    title: 'Seed Firestore (Debug)',
                    subtitle: 'Populate database with test data',
                    onTap: () => Navigator.of(context).pushNamed(MyApp.seedFirestoreRoute),
                  ),
                ],

                const SizedBox(height: 20),

                // App version chip
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kAccentColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      isUrdu ? 'AgriPulse v1.0.0 • پاکستان' : 'AgriPulse v1.0.0 • Pakistan',
                      style: AppFonts.dmSans(context, 
                        color: kTextLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showSoonSnack(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon!'),
        backgroundColor: _deep,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, bool isUrdu) async {
    final bool? should = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isUrdu ? 'لاگ آؤٹ کی تصدیق' : 'Confirm Logout',
          style: AppFonts.dmSans(context, fontWeight: FontWeight.w700),
        ),
        content: Text(
          isUrdu
              ? 'کیا آپ واقعی AgriPulse سے باہر نکلنا چاہتے ہیں؟'
              : 'Are you sure you want to logout from AgriPulse?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isUrdu ? 'منسوخ' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isUrdu ? 'باہر نکلیں' : 'Logout'),
          ),
        ],
      ),
    );

    if (should == true && context.mounted) {
      await AuthService().signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        MyApp.loginRoute,
        (route) => false,
      );
    }
  }
}

// ── Profile Hero ──────────────────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final bool isUrdu;
  const _ProfileHero({required this.isUrdu});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deep, _mid, Color(0xFF40916C)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(top: -30, right: -30,
            child: Container(width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.10)))),
          Positioned(bottom: -20, left: -20,
            child: Container(width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05)))),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseAuth.instance.currentUser?.uid != null
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots()
                    : const Stream.empty(),
                builder: (context, snap) {
                  final data = snap.data?.data() as Map<String, dynamic>?;
                  final name  = data?['fullName'] ?? (isUrdu ? 'کسان' : 'Farmer');
                  final phone = data?['phone']    ?? '+92 000 0000000';
                  final email = FirebaseAuth.instance.currentUser?.email ?? '';

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar
                      Container(
                        width: 84, height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
                      ),
                      const SizedBox(height: 12),
                      Text(name,
                        style: AppFonts.playfairDisplay(context, 
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(phone,
                        style: AppFonts.dmSans(context, color: Colors.white70, fontSize: 13)),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(email,
                          style: AppFonts.dmSans(context, color: Colors.white54, fontSize: 11)),
                      ],
                      const SizedBox(height: 16),
                      // Stat chips
                      Row(
                        children: [
                          Expanded(child: _StatChip(value: '12', label: isUrdu ? 'الرٹس' : 'Alerts')),
                          const SizedBox(width: 8),
                          Expanded(child: _StatChip(value: '3', label: isUrdu ? 'فصلیں' : 'Crops')),
                          const SizedBox(width: 8),
                          Expanded(child: _StatChip(value: '2024', label: isUrdu ? 'رکنیت' : 'Since')),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Text(value,
            style: AppFonts.dmSans(context, color: Colors.white,
                fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
            textAlign: TextAlign.center,
            style: AppFonts.dmSans(context, color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: AppFonts.dmSans(context, 
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kTextLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Premium Tile ──────────────────────────────────────────────────────────────
class _PremiumTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final VoidCallback onTap;
  final bool showArrow;

  const _PremiumTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                        style: AppFonts.dmSans(context, 
                          color: titleColor ?? kTextDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                      const SizedBox(height: 2),
                      Text(subtitle,
                        style: AppFonts.dmSans(context, color: kTextLight, fontSize: 12)),
                    ],
                  ),
                ),
                if (showArrow)
                  Icon(Icons.chevron_right_rounded,
                    color: kTextLight.withValues(alpha: 0.6), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Language Toggle Tile ──────────────────────────────────────────────────────
class _LanguagePremiumTile extends StatelessWidget {
  final LanguageNotifier lang;
  const _LanguagePremiumTile({required this.lang});

  @override
  Widget build(BuildContext context) {
    final isUrdu = lang.isUrdu;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.translate_rounded, color: _deep, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu ? 'زبان' : 'Language',
                    style: AppFonts.dmSans(context, 
                      color: kTextDark, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUrdu ? 'اردو فعال ہے' : 'English is active',
                    style: AppFonts.dmSans(context, color: kTextLight, fontSize: 12),
                  ),
                ],
              ),
            ),
            // EN / UR pill toggle
            GestureDetector(
              onTap: () => lang.toggle(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 72,
                height: 34,
                decoration: BoxDecoration(
                  color: isUrdu ? _deep : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: isUrdu ? _mid : _accent.withValues(alpha: 0.4)),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      left: isUrdu ? 38 : 2,
                      top: 2,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: isUrdu ? _accent : _deep,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6, top: 0, bottom: 0,
                      child: Center(
                        child: Text('EN',
                          style: AppFonts.dmSans(context, 
                            fontSize: 10, fontWeight: FontWeight.w800,
                            color: isUrdu ? Colors.white54 : Colors.white)),
                      ),
                    ),
                    Positioned(
                      right: 6, top: 0, bottom: 0,
                      child: Center(
                        child: Text('UR',
                          style: AppFonts.dmSans(context, 
                            fontSize: 10, fontWeight: FontWeight.w800,
                            color: isUrdu ? Colors.white : kTextLight)),
                      ),
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
