import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';

class MarketOverviewScreen extends StatelessWidget {
  static const String routeName = '/market-overview';

  const MarketOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> provinceData = [
      {'province': 'Punjab', 'open': 12, 'total': 15},
      {'province': 'Sindh', 'open': 8, 'total': 10},
      {'province': 'Khyber Pakhtunkhwa', 'open': 5, 'total': 7},
      {'province': 'Balochistan', 'open': 4, 'total': 6},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Overview'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          const Text(
            'Province-wise Mandi Activity',
            style: TextStyle(
              color: kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...provinceData.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.storefront_outlined, color: kPrimaryColor),
                title: Text(
                  item['province'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${item['open']} open out of ${item['total']} mandis'),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'Top Movers',
            style: TextStyle(
              color: kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const _TrendTile(
            icon: Icons.trending_up,
            iconColor: Colors.green,
            title: 'Tomato',
            subtitle: '+8.2% today',
          ),
          const _TrendTile(
            icon: Icons.trending_down,
            iconColor: Colors.red,
            title: 'Maize',
            subtitle: '-2.1% today',
          ),
        ],
      ),
    );
  }
}

class _TrendTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _TrendTile({
    required this.icon,
    required this.iconColor,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

