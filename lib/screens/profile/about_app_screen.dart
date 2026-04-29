import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';

class AboutAppScreen extends StatelessWidget {
  static const String routeName = '/about';

  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About AgriPulse'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(Icons.eco, size: 64, color: kPrimaryColor),
                SizedBox(height: 10),
                Text(
                  kAppName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Smart Agricultural Market Intelligence',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextLight, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _InfoTile(
            icon: Icons.verified_outlined,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          const _InfoTile(
            icon: Icons.language,
            title: 'Region',
            subtitle: 'Pakistan',
          ),
          const _InfoTile(
            icon: Icons.support_agent,
            title: 'Support',
            subtitle: 'support@agripulse.pk',
          ),
          const _InfoTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Data Policy',
            subtitle: 'Your market preferences are stored locally.',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: kPrimaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

