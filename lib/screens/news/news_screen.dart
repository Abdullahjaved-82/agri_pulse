import '../../utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../services/groq_news_service.dart';
import '../../utils/colors.dart';
import '../../utils/language_provider.dart';
import 'news_detail_screen.dart';

const Color _deep   = Color(0xFF1B4332);
const Color _mid    = Color(0xFF2D6A4F);
const Color _accent = Color(0xFF74C69D);

class NewsScreen extends StatefulWidget {
  static const String routeName = '/news';
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final GroqNewsService _svc = GroqNewsService();

  List<GroqNewsArticle> _articles = [];
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  DateTime? _lastFetch;
  String _activeFilter = 'All';

  static const _filters = ['All', 'Market', 'Weather', 'Government', 'Punjab', 'Export', 'Tips'];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews({bool forceRefresh = false}) async {
    if (forceRefresh) {
      setState(() { _refreshing = true; _error = null; });
    } else {
      setState(() { _loading = true; _error = null; });
    }

    try {
      final articles = await _svc.fetchNews(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _articles      = articles;
          _loading       = false;
          _refreshing    = false;
          _lastFetch     = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error      = 'Could not fetch news. Check your connection.';
          _loading    = false;
          _refreshing = false;
        });
      }
    }
  }

  List<GroqNewsArticle> get _filtered {
    if (_activeFilter == 'All') return _articles;
    return _articles
        .where((a) => a.category.toLowerCase() == _activeFilter.toLowerCase())
        .toList();
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
          // ── Header ──────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _NewsHeaderDelegate(
              isUrdu:      isUrdu,
              lastFetch:   _lastFetch,
              isRefreshing: _refreshing,
              onRefresh:   () => _loadNews(forceRefresh: true),
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _FilterRow(
              filters:      _filters,
              active:       _activeFilter,
              onSelect:     (f) => setState(() => _activeFilter = f),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          if (_loading)
            const SliverFillRemaining(child: _LoadingState())
          else if (_error != null)
            SliverFillRemaining(
              child: _ErrorState(
                message: _error!,
                onRetry:  () => _loadNews(forceRefresh: true),
              ),
            )
          else if (_filtered.isEmpty)
            const SliverFillRemaining(child: _EmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final article = _filtered[i];
                    if (i == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FeaturedCard(article: article),
                          const SizedBox(height: 16),
                          if (_filtered.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(width: 4, height: 18,
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isUrdu ? 'مزید خبریں' : 'More News',
                                    style: AppFonts.dmSans(context, 
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: kTextDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }
                    return _ArticleCard(
                      article: article,
                      onTap: () => Navigator.of(context).pushNamed(
                        NewsDetailScreen.routeName,
                        arguments: article.toMap(),
                      ),
                    );
                  },
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Header Delegate ────────────────────────────────────────────────────────────
class _NewsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isUrdu;
  final DateTime? lastFetch;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  _NewsHeaderDelegate({
    required this.isUrdu,
    required this.lastFetch,
    required this.isRefreshing,
    required this.onRefresh,
  });

  static const double _maxH = 150;
  static const double _minH = 66;

  @override double get maxExtent => _maxH;
  @override double get minExtent => _minH;
  @override bool shouldRebuild(covariant _NewsHeaderDelegate old) =>
      old.isRefreshing != isRefreshing || old.lastFetch != lastFetch || old.isUrdu != isUrdu;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double t = (shrinkOffset / (_maxH - _minH)).clamp(0.0, 1.0);
    final String fetchLabel = lastFetch == null
        ? (isUrdu ? 'لوڈ ہو رہا ہے...' : 'Loading...')
        : (isUrdu
            ? 'آخری اپ ڈیٹ: ${DateFormat('hh:mm a').format(lastFetch!)}'
            : 'Updated ${DateFormat('hh:mm a').format(lastFetch!)}');

    return Container(
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
            child: Container(width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.10)))),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (t < 0.5) ...[
                          Text(
                            isUrdu ? 'تازہ ترین خبریں' : 'Agriculture News',
                            style: AppFonts.playfairDisplay(context, 
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isRefreshing ? Colors.orange : _accent,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isRefreshing
                                    ? (isUrdu ? 'اپ ڈیٹ ہو رہا ہے...' : 'Refreshing...')
                                    : fetchLabel,
                                style: AppFonts.dmSans(context, 
                                  color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ] else
                          Text(
                            isUrdu ? 'زرعی خبریں' : 'Agri News',
                            style: AppFonts.dmSans(context, 
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                  // Refresh button
                  GestureDetector(
                    onTap: isRefreshing ? null : onRefresh,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: isRefreshing
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // LIVE badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 5, height: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white)),
                        const SizedBox(width: 4),
                        Text('LIVE',
                          style: AppFonts.dmSans(context, 
                            color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ],
                    ),
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

// ── Filter Row ────────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final String active;
  final ValueChanged<String> onSelect;
  const _FilterRow({required this.filters, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filters[i];
          final sel = f == active;
          return GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? kPrimaryColor : kBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? kPrimaryColor : kTextLight.withValues(alpha: 0.3)),
              ),
              child: Text(f,
                style: AppFonts.dmSans(context, 
                  color: sel ? Colors.white : kTextDark,
                  fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}

// ── Featured Card ─────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final GroqNewsArticle article;
  const _FeaturedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        NewsDetailScreen.routeName, arguments: article.toMap()),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [_deep, _mid, Color(0xFF40916C)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: _deep.withValues(alpha: 0.25),
              blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            // decorative circle
            Positioned(top: -20, right: -20,
              child: Container(width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07)))),
            // Live badge
            if (article.isLive)
              Positioned(top: 14, left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(6)),
                  child: Text('LIVE AI',
                    style: AppFonts.dmSans(context, 
                      color: Colors.white, fontSize: 9,
                      fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
            // Emoji
            Positioned(top: 12, right: 14,
              child: Text(article.emoji,
                style: const TextStyle(fontSize: 44))),
            // Bottom content
            Positioned(left: 14, right: 14, bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(article.category,
                      style: AppFonts.dmSans(context, 
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 6),
                  Text(article.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: AppFonts.playfairDisplay(context, 
                      color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 6),
                  Text(article.date,
                    style: AppFonts.dmSans(context, color: Colors.white60, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Article Card ──────────────────────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final GroqNewsArticle article;
  final VoidCallback onTap;
  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category color stripe
            Container(
              width: 4, height: 60,
              decoration: BoxDecoration(
                color: _categoryColor(article.category),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _categoryColor(article.category).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(article.category,
                          style: AppFonts.dmSans(context, 
                            color: _categoryColor(article.category),
                            fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      const Spacer(),
                      if (article.isLive)
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green)),
                      const SizedBox(width: 4),
                      Text(article.date,
                        style: AppFonts.dmSans(context, color: kTextLight, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(article.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: AppFonts.dmSans(context, 
                      color: kTextDark, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(article.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: AppFonts.dmSans(context, color: kTextLight, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(article.emoji, style: const TextStyle(fontSize: 28)),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'market':  return const Color(0xFF2D6A4F);
      case 'weather': return const Color(0xFF1565C0);
      case 'government': return const Color(0xFF6A1B9A);
      case 'export': return const Color(0xFFE65100);
      case 'punjab': return const Color(0xFF00838F);
      default:       return kPrimaryColor;
    }
  }
}

// ── Loading State ─────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: kPrimaryColor),
          const SizedBox(height: 16),
          Text('Fetching live agriculture news...',
            style: AppFonts.dmSans(context, color: kTextLight, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: kTextLight),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center,
              style: AppFonts.dmSans(context, color: kTextLight, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.newspaper_rounded, size: 48, color: kTextLight),
          const SizedBox(height: 12),
          Text('No news in this category',
            style: AppFonts.dmSans(context, color: kTextLight, fontSize: 13)),
        ],
      ),
    );
  }
}
