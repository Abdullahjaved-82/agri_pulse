import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/news_card.dart';
import '../profile/profile_screen.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  static const String routeName = '/news';

  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const List<String> _filters = [
    'All',
    'Market',
    'Weather',
    'Government',
    'Tips',
  ];

  String _activeFilter = 'All';

  List<Map<String, dynamic>> get _filteredNews {
    final List<Map<String, dynamic>> source = List<Map<String, dynamic>>.from(
      DummyData.news,
    );

    if (_activeFilter == 'All') {
      return source;
    }

    return source.where((item) => _matchesFilter(item)).toList();
  }

  bool _matchesFilter(Map<String, dynamic> item) {
    final String title = (item['title'] as String? ?? '').toLowerCase();
    final String description =
        (item['description'] as String? ?? '').toLowerCase();
    final String category = (item['category'] as String? ?? '').toLowerCase();

    switch (_activeFilter) {
      case 'Market':
        return title.contains('market') ||
            category.contains('market') ||
            category.contains('export') ||
            title.contains('prices');
      case 'Weather':
        return title.contains('rain') ||
            title.contains('weather') ||
            description.contains('moisture') ||
            description.contains('irrigation');
      case 'Government':
        return title.contains('advisory') ||
            category.contains('advisory') ||
            description.contains('extension');
      case 'Tips':
        return title.contains('advisory') ||
            description.contains('advise') ||
            description.contains('growers');
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = _filteredNews;
    final Map<String, dynamic>? featured = items.isEmpty ? null : items.first;
    final List<Map<String, dynamic>> regularItems =
        items.length > 1 ? items.skip(1).toList() : const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agriculture News'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
            icon: const Icon(Icons.person_outline),
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
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final String filter = _filters[index];
                final bool isSelected = _activeFilter == filter;

                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _activeFilter = filter;
                    });
                  },
                  selectedColor: kPrimaryColor,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? kPrimaryColor
                        : kTextLight.withValues(alpha: 0.3),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : kTextDark,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          if (featured != null) _FeaturedNewsCard(news: featured),
          if (regularItems.isNotEmpty) const SizedBox(height: 12),
          ...regularItems.map((item) {
            return NewsCard(
              emoji: item['emoji'] as String,
              title: item['title'] as String,
              description: item['description'] as String,
              date: item['date'] as String,
              category: item['category'] as String,
              onTap: () {
                Navigator.of(context).pushNamed(
                  NewsDetailScreen.routeName,
                  arguments: item,
                );
              },
            );
          }),
          if (items.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No news available for this filter right now.',
                style: TextStyle(
                  color: kTextLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedNewsCard extends StatelessWidget {
  final Map<String, dynamic> news;

  const _FeaturedNewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final String title = news['title'] as String? ?? '';
    final String date = news['date'] as String? ?? '';
    final String category = news['category'] as String? ?? '';
    final String emoji = news['emoji'] as String? ?? '📰';

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          NewsDetailScreen.routeName,
          arguments: news,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryColor, kSecondaryColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 46),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


