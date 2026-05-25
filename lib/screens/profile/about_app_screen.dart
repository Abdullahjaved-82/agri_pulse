import '../../utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/colors.dart';
import '../../utils/language_provider.dart';

const Color _deep   = Color(0xFF1B4332);
const Color _mid    = Color(0xFF2D6A4F);
const Color _accent = Color(0xFF74C69D);

Future<void> _openDeveloperSite() async {
  final uri = Uri.parse('https://abdullahjaved.site');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class AboutAppScreen extends StatelessWidget {
  static const String routeName = '/about';
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang   = LanguageScope.of(context);
    final isUrdu = lang.isUrdu;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: _deep,
            foregroundColor: Colors.white,
            title: Text(
              isUrdu ? 'ایپ کے بارے میں' : 'About AgriPulse',
              style: AppFonts.dmSans(context, fontWeight: FontWeight.w700),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _AboutHero(isUrdu: isUrdu),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Mission Card
                _MissionCard(isUrdu: isUrdu),
                const SizedBox(height: 20),

                // Info tiles
                _SectionLabel(isUrdu ? 'ایپ کی معلومات' : 'App Information'),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.verified_rounded,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: _deep,
                  title: isUrdu ? 'ورژن' : 'Version',
                  value: '1.0.0',
                ),
                _InfoTile(
                  icon: Icons.flag_rounded,
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  title: isUrdu ? 'علاقہ' : 'Region',
                  value: isUrdu ? 'پاکستان' : 'Pakistan',
                ),
                _InfoTile(
                  icon: Icons.translate_rounded,
                  iconBg: const Color(0xFFF3E5F5),
                  iconColor: Colors.purple,
                  title: isUrdu ? 'زبانیں' : 'Languages',
                  value: isUrdu ? 'اردو، انگریزی' : 'English, Urdu',
                ),

                const SizedBox(height: 20),

                _SectionLabel(isUrdu ? 'سپورٹ اور رابطہ' : 'Support & Contact'),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.support_agent_rounded,
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFE65100),
                  title: isUrdu ? 'سپورٹ' : 'Support',
                  value: 'support@agripulse.pk',
                ),
                _InfoTile(
                  icon: Icons.privacy_tip_rounded,
                  iconBg: const Color(0xFFFFEBEE),
                  iconColor: Colors.red.shade700,
                  title: isUrdu ? 'ڈیٹا پالیسی' : 'Data Policy',
                  value: isUrdu
                      ? 'آپ کی ترجیحات مقامی طور پر محفوظ ہیں'
                      : 'Your preferences are stored locally',
                ),

                const SizedBox(height: 20),
                _SectionLabel(isUrdu ? 'ڈویلپر' : 'Developer'),
                const SizedBox(height: 10),
                _DeveloperCard(isUrdu: isUrdu),

                const SizedBox(height: 20),

                // Feature list
                _SectionLabel(isUrdu ? 'اہم خصوصیات' : 'Key Features'),
                const SizedBox(height: 10),
                _FeatureGrid(isUrdu: isUrdu),

                const SizedBox(height: 24),

                // Footer
                Center(
                  child: Text(
                    isUrdu
                        ? '© 2024 AgriPulse — پاکستان کے کسانوں کے لیے'
                        : '© 2024 AgriPulse — Built for Pakistan\'s Farmers',
                    textAlign: TextAlign.center,
                    style: AppFonts.dmSans(context, 
                        color: kTextLight, fontSize: 12),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────
class _AboutHero extends StatelessWidget {
  final bool isUrdu;
  const _AboutHero({required this.isUrdu});

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
          Positioned(top: -20, right: -20,
            child: Container(width: 120, height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.10)))),
          SafeArea(
            bottom: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                      ),
                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 38),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'Agri',
                          style: AppFonts.playfairDisplay(context,
                            color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                        TextSpan(text: 'Pulse',
                          style: AppFonts.playfairDisplay(context,
                            color: _accent, fontSize: 26, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUrdu ? 'زرعی مارکیٹ انٹیلیجنس' : 'Agricultural Market Intelligence',
                      style: AppFonts.dmSans(context,
                          color: Colors.white60, fontSize: 12, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mission Card ──────────────────────────────────────────────────────────────
class _MissionCard extends StatelessWidget {
  final bool isUrdu;
  const _MissionCard({required this.isUrdu});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_deep, _mid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _deep.withValues(alpha: 0.25),
            blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUrdu ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUrdu) ...[
                const Icon(Icons.format_quote_rounded, color: _accent, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                isUrdu ? 'ہمارا مشن' : 'Our Mission',
                style: AppFonts.dmSans(context,
                  color: _accent, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5),
              ),
              if (isUrdu) ...[
                const SizedBox(width: 8),
                const Icon(Icons.format_quote_rounded, color: _accent, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isUrdu
                ? 'AgriPulse پاکستان کے کسانوں کو ریئل ٹائم مارکیٹ ڈیٹا، موسم کی پیش گوئی اور AI مشاورت فراہم کر کے بہتر فیصلے کرنے میں مدد کرتا ہے۔'
                : 'AgriPulse empowers Pakistani farmers with real-time market data, weather forecasts, and AI-powered advisory to make better decisions for their harvest and livelihood.',
            textAlign: isUrdu ? TextAlign.right : TextAlign.left,
            style: AppFonts.dmSans(context,
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Tile ─────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String value;
  const _InfoTile({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    color: kTextLight, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                  style: AppFonts.dmSans(context,
                    color: kTextDark, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature Grid ─────────────────────────────────────────────────────────────
class _FeatureGrid extends StatelessWidget {
  final bool isUrdu;
  const _FeatureGrid({required this.isUrdu});

  @override
  Widget build(BuildContext context) {
    final features = isUrdu ? [
      (Icons.bar_chart_rounded,     'ریئل ٹائم قیمتیں'),
      (Icons.cloud_rounded,         'موسم کی پیش گوئی'),
      (Icons.auto_awesome_rounded,  'AI مشاورت'),
      (Icons.store_rounded,         'منڈی کی فہرست'),
      (Icons.newspaper_rounded,     'زرعی خبریں'),
      (Icons.calculate_rounded,     'ٹولز'),
    ] : [
      (Icons.bar_chart_rounded,     'Live Market Prices'),
      (Icons.cloud_rounded,         'Weather Forecasts'),
      (Icons.auto_awesome_rounded,  'AI Advisory'),
      (Icons.store_rounded,         'Mandi Directory'),
      (Icons.newspaper_rounded,     'Agri News'),
      (Icons.calculate_rounded,     'Farming Tools'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, i) {
        final f = features[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Icon(f.$1, color: _deep, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(f.$2,
                  style: AppFonts.dmSans(context,
                    fontSize: 11, fontWeight: FontWeight.w600, color: kTextDark),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
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
          fontSize: 11, fontWeight: FontWeight.w700,
          color: kTextLight, letterSpacing: 1.2),
      ),
    );
  }
}

// ── Developer Card ─────────────────────────────────────────────────────────────
class _DeveloperCard extends StatelessWidget {
  final bool isUrdu;
  const _DeveloperCard({required this.isUrdu});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isUrdu ? 'عبداللہ جاوید' : 'Abdullah Javed',
            style: AppFonts.dmSans(context,
              color: kTextDark, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            isUrdu
                ? 'سافٹ ویئر انجینئر | اے آئی اور آٹومیشن اسپیشلسٹ'
                : 'Software Engineer | AI & Automation Specialist',
            style: AppFonts.dmSans(context, color: kTextLight, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            isUrdu
                ? 'فل اسٹیک ڈیولپر جو Next.js اور MERN اسٹیک کے ساتھ ذہین سسٹمز بناتا ہے۔ Cloudora کے شریک بانی۔ اے آئی، مشین لرننگ، اور بزنس آٹومیشن پر فوکس۔'
                : 'Full-stack developer building intelligent systems with Next.js & MERN stack. Co-founder of Cloudora. Focused on AI, Machine Learning, and business automation.',
            style: AppFonts.dmSans(context,
              color: kTextLight, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _openDeveloperSite,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, size: 18, color: _deep),
                  const SizedBox(width: 8),
                  Text(
                    'abdullahjaved.site',
                    style: AppFonts.dmSans(context,
                      color: _deep, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => launchUrl(Uri.parse('mailto:abdullahjavec@gmail.com')),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.email_rounded, size: 18, color: _deep),
                  const SizedBox(width: 8),
                  Text(
                    'abdullahjavec@gmail.com',
                    style: AppFonts.dmSans(context,
                      color: _deep, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => launchUrl(Uri.parse('https://github.com/Abdullahjaved-82')),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.code_rounded, size: 18, color: _deep),
                  const SizedBox(width: 8),
                  Text(
                    'github.com/Abdullahjaved-82',
                    style: AppFonts.dmSans(context,
                      color: _deep, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => launchUrl(Uri.parse('https://www.linkedin.com/in/abdullah-javed-8468a7343')),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.work_rounded, size: 18, color: _deep),
                  const SizedBox(width: 8),
                  Text(
                    'linkedin.com/in/abdullah-javed-8468a7343',
                    style: AppFonts.dmSans(context,
                      color: _deep, fontSize: 13, fontWeight: FontWeight.w700),
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
