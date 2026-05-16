import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/groq_news_service.dart';
import '../../utils/colors.dart';

const Color _deep = Color(0xFF1B4332);
const Color _mid  = Color(0xFF2D6A4F);

class NewsDetailScreen extends StatelessWidget {
  static const String routeName = '/news-detail';

  const NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accept both GroqNewsArticle.toMap() and old raw maps
    final Map<String, dynamic> news =
        (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?) ?? {};

    final article = GroqNewsArticle.fromMap(news);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: _deep,
            foregroundColor: Colors.white,
            title: Text(article.category,
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Share coming soon.'),
                    backgroundColor: _deep,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_deep, _mid, Color(0xFF40916C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(top: -20, right: -20,
                      child: Container(width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07)))),
                    Center(
                      child: Text(article.emoji,
                        style: const TextStyle(fontSize: 80)),
                    ),
                    if (article.isLive)
                      Positioned(bottom: 14, left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 6, height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white)),
                              const SizedBox(width: 5),
                              Text('AI-GENERATED',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white, fontSize: 9,
                                  fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Article Content ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Category chip + date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kAccentColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(article.category,
                        style: GoogleFonts.dmSans(
                          color: kPrimaryColor,
                          fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Text(article.date,
                      style: GoogleFonts.dmSans(color: kTextLight, fontSize: 12)),
                    if (article.isLive) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Live AI',
                          style: GoogleFonts.dmSans(
                            color: Colors.green.shade700,
                            fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(article.title,
                  style: GoogleFonts.playfairDisplay(
                    color: kTextDark, fontSize: 24,
                    fontWeight: FontWeight.w700, height: 1.3)),
                const SizedBox(height: 20),

                // Divider
                Container(height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0)]),
                  ),
                ),
                const SizedBox(height: 20),

                // Body
                Text(_buildBody(article.description),
                  style: GoogleFonts.dmSans(
                    color: kTextDark, fontSize: 15, height: 1.75)),

                const SizedBox(height: 30),

                // Source note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kAccentColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                        color: kPrimaryColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          article.isLive
                              ? 'This article was generated by Groq AI (Llama 3.1) based on current Pakistan agricultural market conditions.'
                              : 'This article is from AgriPulse curated database.',
                          style: GoogleFonts.dmSans(
                            color: kTextLight, fontSize: 11, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _buildBody(String summary) {
    // Expand the summary into a fuller article body
    return '$summary\n\nIn recent weeks, farmers and traders across Punjab and Sindh have been monitoring significant shifts in agricultural market dynamics. Weather patterns, government procurement policies, and global commodity prices are all contributing to the current situation.\n\nField observations from extension teams reveal that growers with better access to market information are making more profitable decisions. Digital tools like AgriPulse are helping bridge this information gap, allowing farmers to compare prices across different mandis before deciding when and where to sell.\n\nExperts recommend that farmers track price trends over multiple days rather than reacting to single-day fluctuations. Maintaining proper storage conditions and staggering sales can significantly improve net returns even in volatile market conditions.\n\nTraders also note that transportation costs and fuel prices remain major factors in final mandi prices. Farmers located farther from major mandis should factor in these costs when evaluating offers from local buyers versus traveling to urban markets.';
  }
}
