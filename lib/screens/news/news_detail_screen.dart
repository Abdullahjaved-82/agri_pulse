import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';

class NewsDetailScreen extends StatelessWidget {
  static const String routeName = '/news-detail';

  final Map<String, dynamic> news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final String title = news['title'] as String? ?? '';
    final String emoji = news['emoji'] as String? ?? '📰';
    final String date = news['date'] as String? ?? '';
    final String category = news['category'] as String? ?? 'News';

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon.')),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          kDefaultPadding,
          14,
          kDefaultPadding,
          20,
        ),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPrimaryColor,
                  kSecondaryColor.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: kTextDark,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: kTextLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kAccentColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _articleBody(news['description'] as String? ?? ''),
            style: const TextStyle(
              color: kTextDark,
              fontSize: 15,
              height: 1.62,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _articleBody(String shortDescription) {
    return '$shortDescription In recent weeks across Pakistan, farmers, traders, and mandi committees have been watching a clear shift in crop behavior due to mixed weather, changing transport costs, and timely irrigation decisions. Field visits in Punjab and Sindh show that better moisture in some districts has improved grain quality, while late arrivals in other regions are creating short-lived price swings. Extension teams continue advising growers to stagger harvest and maintain storage hygiene so marketable stock remains consistent. Traders say demand from feed mills and flour units is steady, but they expect volatility whenever fuel prices rise or transport routes slow down. Experts recommend that farmers compare daily mandi rates before selling, keep records of input costs, and avoid panic sales during temporary dips. With smarter timing, improved grading, and better coordination between growers and buyers, many producers can protect margins and reduce post-harvest losses even in uncertain market conditions.';
  }
}

