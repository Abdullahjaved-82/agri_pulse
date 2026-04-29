import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import '../../data/dummy_data.dart';
import '../../models/mandi_model.dart';
import '../../utils/colors.dart';
import '../../widgets/crop_price_tile.dart';
import '../../widgets/mandi_card.dart';
import '../../widgets/news_card.dart';
import '../../screens/crop/crop_list_screen.dart';
import '../../screens/mandi/mandi_detail_screen.dart';
import '../../screens/mandi/mandi_list_screen.dart';
import '../../screens/news/news_detail_screen.dart';
import '../../screens/news/news_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/tools/tools_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _HomeTab(
        onViewAllCrops: () {
          Navigator.of(context).pushNamed(CropListScreen.routeName);
        },
        onViewAllMandis: () {
          Navigator.of(context).pushNamed(MandiListScreen.routeName);
        },
      ),
      const CropListScreen(),
      const MandiListScreen(),
      const ToolsScreen(),
      const NewsScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final bool shouldExit = await _showExitDialog();
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: IndexedStack(index: _selectedIndex, children: tabs),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kTextLight,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Crops'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Mandi'),
            BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Tools'),
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Exit AgriPulse?'),
          content: const Text('Do you want to close the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onViewAllCrops;
  final VoidCallback onViewAllMandis;

  const _HomeTab({
    required this.onViewAllCrops,
    required this.onViewAllMandis,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> crops = DummyData.crops.take(4).toList();
    final List<Map<String, dynamic>> mandis = DummyData.mandis.take(2).toList();
    final List<Map<String, dynamic>> news = DummyData.news.take(2).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 130,
          backgroundColor: kPrimaryColor,
          centerTitle: true,
          title: const Text('AgriPulse'),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kPrimaryColor, kSecondaryColor],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Good Morning, Farmer 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'AgriPulse',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(MyApp.notificationsRoute);
                        },
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(ProfileScreen.routeName);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: SizedBox(
                height: 118,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _SummaryCard(
                      title: "Today's Markets",
                      subtitle: '12 Open',
                      icon: Icons.storefront_outlined,
                      color: Colors.green,
                    ),
                    SizedBox(width: 12),
                    _SummaryCard(
                      title: 'Price Alerts',
                      subtitle: '2 Active',
                      icon: Icons.notifications_active_outlined,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 12),
                    _SummaryCard(
                      title: 'Top Crop',
                      subtitle: 'Wheat ↑',
                      icon: Icons.grass,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const _SectionHeader(title: 'Quick Access'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.assessment_outlined,
                      title: 'Market Overview',
                      subtitle: 'Live mandi activity',
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(MyApp.marketOverviewRoute);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.cloud_outlined,
                      title: 'Weather',
                      subtitle: '7-day advisory',
                      onTap: () {
                        Navigator.of(context).pushNamed(MyApp.weatherRoute);
                      },
                    ),
                  ),
                ],
              ),
            ),
            _SectionHeader(
              title: "Today's Top Prices",
              actionText: 'View All',
              onActionTap: onViewAllCrops,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: crops.map((crop) {
                  final double price = (crop['price'] as num).toDouble();
                  final double previousPrice = (crop['previousPrice'] as num)
                      .toDouble();
                  final String trend = crop['trend'] as String;
                  final double change = previousPrice == 0
                      ? 0
                      : ((price - previousPrice) / previousPrice * 100).abs();

                  return CropPriceTile(
                    emoji: crop['imageEmoji'] as String,
                    name: crop['name'] as String,
                    price: price,
                    unit: crop['unit'] as String,
                    trend: trend,
                    percentChange: trend == 'stable' ? 0 : change,
                  );
                }).toList(),
              ),
            ),
            _SectionHeader(
              title: 'Nearby Mandis',
              actionText: 'View All',
              onActionTap: onViewAllMandis,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: mandis
                    .map(
                      (mandiMap) {
                        final MandiModel mandi = MandiModel.fromMap(mandiMap);
                        return MandiCard(
                          name: mandi.name,
                          city: mandi.city,
                          province: mandi.province,
                          distance: mandi.distance,
                          isOpen: mandi.isOpen,
                          totalCrops: mandi.totalCrops,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              MandiDetailScreen.routeName,
                              arguments: mandi,
                            );
                          },
                        );
                      },
                    )
                    .toList(),
              ),
            ),
            const _SectionHeader(title: 'Latest News'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: news
                    .map(
                      (item) => NewsCard(
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
                      ),
                    )
                    .toList(),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionText!,
                style: const TextStyle(
                  color: kSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kTextDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: kTextLight,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: kPrimaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: kTextDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: kTextLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

