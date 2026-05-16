import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/notification_service.dart';
import '../../utils/colors.dart';
import '../../utils/language_provider.dart';

const Color _deep   = Color(0xFF1B4332);
const Color _mid    = Color(0xFF2D6A4F);
const Color _accent = Color(0xFF74C69D);

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _marketAlerts  = true;
  bool _newsAlerts    = true;
  bool _weatherAlerts = false;
  bool _priceDrops    = true;

  Future<void> _sendTestNotification(bool isUrdu) async {
    await NotificationService.instance.showTestNotification(
      title: isUrdu ? 'AgriPulse اطلاع' : 'AgriPulse Alert',
      body: isUrdu
          ? 'لاہور منڈی میں گندم کی قیمت آپ کے ہدف تک پہنچ گئی ہے۔'
          : 'Wheat crossed your target price in Lahore mandi.',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isUrdu ? 'ٹیسٹ اطلاع بھیجی گئی۔' : 'Test notification sent.'),
        backgroundColor: _deep,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang   = LanguageScope.of(context);
    final isUrdu = lang.isUrdu;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ─────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: _deep,
            foregroundColor: Colors.white,
            title: Text(
              isUrdu ? 'اطلاعات' : 'Notifications',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _NotifHero(isUrdu: isUrdu),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Active count chip
                _ActiveChip(
                  count: [_marketAlerts, _newsAlerts, _weatherAlerts, _priceDrops]
                      .where((b) => b).length,
                  isUrdu: isUrdu,
                ),
                const SizedBox(height: 20),

                // Section: Market
                _SectionLabel(isUrdu ? 'مارکیٹ اطلاعات' : 'Market Alerts'),
                const SizedBox(height: 10),
                _NotifTile(
                  icon: Icons.trending_up_rounded,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: _deep,
                  title: isUrdu ? 'مارکیٹ قیمت اطلاعات' : 'Market Price Alerts',
                  subtitle: isUrdu
                      ? 'منڈی میں ریئل ٹائم قیمتوں کی تبدیلی'
                      : 'Real-time mandi price movements',
                  value: _marketAlerts,
                  onChanged: (v) => setState(() => _marketAlerts = v),
                ),
                _NotifTile(
                  icon: Icons.arrow_downward_rounded,
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: Colors.red.shade600,
                  title: isUrdu ? 'قیمت گرنے کی اطلاع' : 'Price Drop Alerts',
                  subtitle: isUrdu
                      ? 'جب قیمت آپ کی حد سے نیچے آئے'
                      : 'When price falls below your threshold',
                  value: _priceDrops,
                  onChanged: (v) => setState(() => _priceDrops = v),
                ),

                const SizedBox(height: 20),

                // Section: News & Weather
                _SectionLabel(isUrdu ? 'خبریں اور موسم' : 'News & Weather'),
                const SizedBox(height: 10),
                _NotifTile(
                  icon: Icons.newspaper_rounded,
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFE65100),
                  title: isUrdu ? 'زرعی خبریں' : 'Agriculture News',
                  subtitle: isUrdu
                      ? 'روزانہ پالیسی اور فصل کی خبریں'
                      : 'Daily policy, weather and crop updates',
                  value: _newsAlerts,
                  onChanged: (v) => setState(() => _newsAlerts = v),
                ),
                _NotifTile(
                  icon: Icons.cloud_rounded,
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  title: isUrdu ? 'موسمی مشاورت' : 'Weather Advisories',
                  subtitle: isUrdu
                      ? 'آنے والے موسم کی مقامی رہنمائی'
                      : 'Localized guidance for upcoming conditions',
                  value: _weatherAlerts,
                  onChanged: (v) => setState(() => _weatherAlerts = v),
                ),

                const SizedBox(height: 28),

                // Test button
                _TestNotifButton(
                  isUrdu: isUrdu,
                  onTap: () => _sendTestNotification(isUrdu),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notif Hero ────────────────────────────────────────────────────────────────
class _NotifHero extends StatelessWidget {
  final bool isUrdu;
  const _NotifHero({required this.isUrdu});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deep, _mid, Color(0xFF40916C)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -10, right: -20,
            child: Container(width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.10)))),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    isUrdu ? 'اطلاعات کا انتظام کریں' : 'Manage your alerts & updates',
                    style: GoogleFonts.dmSans(
                      color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active Count Chip ─────────────────────────────────────────────────────────
class _ActiveChip extends StatelessWidget {
  final int count;
  final bool isUrdu;
  const _ActiveChip({required this.count, required this.isUrdu});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.done_all_rounded, color: _deep, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrdu ? '$count اطلاعات فعال ہیں' : '$count Notifications Active',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w800, fontSize: 15, color: kTextDark),
                ),
                Text(
                  isUrdu ? 'آپ کی ترجیحات محفوظ ہیں' : 'Your preferences are saved',
                  style: GoogleFonts.dmSans(color: kTextLight, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _deep,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('$count',
                style: GoogleFonts.dmSans(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification Tile ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.subtitle,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value ? Colors.white : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? _accent.withValues(alpha: 0.3) : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: value ? 0.06 : 0.03),
            blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: value ? iconBg : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: value ? iconColor : kTextLight, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.dmSans(
                    color: value ? kTextDark : kTextLight,
                    fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                  style: GoogleFonts.dmSans(color: kTextLight, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _deep,
            activeTrackColor: _accent.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

// ── Test Button ───────────────────────────────────────────────────────────────
class _TestNotifButton extends StatelessWidget {
  final bool isUrdu;
  final VoidCallback onTap;
  const _TestNotifButton({required this.isUrdu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_deep, _mid],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _deep.withValues(alpha: 0.30),
              blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              isUrdu ? 'ٹیسٹ اطلاع بھیجیں' : 'Send Test Notification',
              style: GoogleFonts.dmSans(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
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
        style: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: kTextLight, letterSpacing: 1.2),
      ),
    );
  }
}
