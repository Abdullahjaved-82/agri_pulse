import '../../utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import '../../data/dummy_data.dart';
import '../../models/mandi_model.dart';
import '../../services/groq_news_service.dart';
import '../../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/colors.dart';
import '../../widgets/crop_price_tile.dart';
import '../../widgets/mandi_card.dart';
import '../../widgets/news_card.dart';
import '../../screens/crop/crop_list_screen.dart';
import '../../screens/crop/crop_detail_screen.dart';
import '../../screens/crop/edibles_list_screen.dart';
import '../../screens/mandi/mandi_detail_screen.dart';
import '../../screens/mandi/mandi_list_screen.dart';
import '../../screens/news/news_detail_screen.dart';
import '../../screens/news/news_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/tools/tools_screen.dart';
import '../../widgets/ai_advisory_card.dart';
import '../../services/firestore_service.dart';
import '../../utils/language_provider.dart';
import '../../models/crop_model.dart';
import '../../services/price_alert_service.dart';
import '../../screens/alerts/price_alert_screen.dart';
import '../../services/weather_service.dart';

// ── Palette extras ────────────────────────────────────────────────────────────
const Color _deep   = Color(0xFF1B4332);
const Color _mid    = Color(0xFF2D6A4F);
const Color _accent = Color(0xFF74C69D);
const Color _gold   = Color(0xFFFFE082);

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
        onViewAllCrops:  () => Navigator.of(context).pushNamed(CropListScreen.routeName),
        onViewAllMandis: () => Navigator.of(context).pushNamed(MandiListScreen.routeName),
      ),
      const CropListScreen(),
      const EdiblesListScreen(),
      const ToolsScreen(),
      const NewsScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _showExitDialog()) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: tabs[_selectedIndex],
        bottomNavigationBar: _PremiumNavBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    final bool isUrdu = LanguageScope.of(context).isUrdu;
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(isUrdu ? 'AgriPulse سے باہر نکلیں؟' : 'Exit AgriPulse?',
            style: AppFonts.dmSans(context, fontWeight: FontWeight.w700)),
        content: Text(isUrdu ? 'کیا آپ ایپ کو بند کرنا چاہتے ہیں؟' : 'Do you want to close the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isUrdu ? 'منسوخ' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isUrdu ? 'باہر نکلیں' : 'Exit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ── Premium Bottom Nav ────────────────────────────────────────────────────────
class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _PremiumNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUrdu = LanguageScope.of(context).isUrdu;
    final items = [
      (icon: Icons.home_rounded,        label: isUrdu ? 'ہوم' : 'Home'),
      (icon: Icons.grass_rounded,       label: isUrdu ? 'فصلیں' : 'Crops'),
      (icon: Icons.local_dining_rounded,label: isUrdu ? 'خوراک' : 'Edibles'),
      (icon: Icons.calculate_rounded,   label: isUrdu ? 'ٹولز' : 'Tools'),
      (icon: Icons.newspaper_rounded,   label: isUrdu ? 'خبریں' : 'News'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _deep.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final bool sel = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? kPrimaryColor.withValues(alpha: 0.10) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon,
                            size: 22,
                            color: sel ? kPrimaryColor : kTextLight),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: AppFonts.dmSans(context,
                            fontSize: 10,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel ? kPrimaryColor : kTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final VoidCallback onViewAllCrops;
  final VoidCallback onViewAllMandis;
  const _HomeTab({required this.onViewAllCrops, required this.onViewAllMandis});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final GroqNewsService _newsSvc = GroqNewsService();
  final LocationService _locSvc = LocationService();
  final WeatherService _weatherSvc = WeatherService();
  
  List<GroqNewsArticle> _homeNews = [];
  bool _newsLoading = true;
  Position? _currentPosition;
  int _activeAlertsCount = 0;
  
  String _weatherTemp = '28°C';
  String _weatherCity = 'Lahore';

  @override
  void initState() {
    super.initState();
    _loadNews();
    _initLocation();
    _loadAlerts();
    if (kDebugMode) {
      _seedFirebaseData();
    }
  }

  Future<void> _loadAlerts() async {
    try {
      await PriceAlertService.instance.load();
      if (mounted) {
        setState(() {
          _activeAlertsCount = PriceAlertService.instance.activeCount;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('PriceAlerts load failed: $e');
      }
    }
  }

  Future<void> _seedFirebaseData() async {
    try {
      final svc = FirestoreService();
      await svc.seedInitialData(DummyData.crops, cropPriceHistory);
    } catch (e) {
      if (kDebugMode) {
        print('Firebase seeding failed/skipped: $e');
      }
    }
  }

  Future<void> _loadHomeWeather() async {
    if (_currentPosition == null) return;
    try {
      final report = await _weatherSvc.fetchForecastByCoords(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        days: 1,
      );
      if (mounted) {
        setState(() {
          _weatherTemp = '${report.currentTempC.toStringAsFixed(0)}°C';
          _weatherCity = report.locationName;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Home weather load failed: $e');
      }
    }
  }

  Future<void> _initLocation() async {
    try {
      final pos = await _locSvc.getCurrentLocation();
      if (!mounted) return;
      if (pos != null) {
        setState(() => _currentPosition = pos);
        await _loadHomeWeather();
      } else {
        await _showLocationDialog();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Location initialization failed: $e');
      }
    }
  }

  Future<void> _showLocationDialog() async {
    final isUrdu = LanguageScope.of(context).isUrdu;
    final serviceEnabled = await _locSvc.isServiceEnabled();
    final permission = await _locSvc.checkPermission();
    if (!mounted) return;

    final String title;
    final String message;
    final String actionLabel;
    final Future<bool> Function() action;

    if (!serviceEnabled) {
      title = isUrdu ? 'لوکیشن بند ہے' : 'Location Disabled';
      message = isUrdu
          ? 'قریبی منڈیاں دیکھنے کے لیے لوکیشن آن کریں۔'
          : 'Turn on location services to see nearby mandis.';
      actionLabel = isUrdu ? 'لوکیشن آن کریں' : 'Open Location';
      action = _locSvc.openLocationSettings;
    } else if (permission == LocationPermission.deniedForever) {
      title = isUrdu ? 'اجازت مستقل طور پر بند ہے' : 'Permission Permanently Denied';
      message = isUrdu
          ? 'اجازت دینے کے لیے ایپ سیٹنگز کھولیں۔'
          : 'Open app settings to grant location permission.';
      actionLabel = isUrdu ? 'ایپ سیٹنگز' : 'App Settings';
      action = _locSvc.openAppSettings;
    } else {
      title = isUrdu ? 'لوکیشن کی اجازت درکار ہے' : 'Location Permission Needed';
      message = isUrdu
          ? 'قریبی منڈیاں اور فاصلے دکھانے کے لیے اجازت دیں۔'
          : 'Allow location permission to show nearby mandis and distance.';
      actionLabel = isUrdu ? 'اجازت دیں' : 'Allow';
      action = () async {
        await _locSvc.getCurrentLocation();
        return true;
      };
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: AppFonts.dmSans(ctx, fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isUrdu ? 'بعد میں' : 'Not now'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await action();
              if (mounted) {
                await _initLocation();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _loadNews() async {
    try {
      final articles = await _newsSvc.fetchNews();
      if (mounted) setState(() { _homeNews = articles.take(2).toList(); _newsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _newsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = LanguageScope.of(context).isUrdu;
    final svc            = FirestoreService();
    final fallbackCrops  = DummyData.crops.take(4).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero header ──────────────────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _HeroHeaderDelegate(isUrdu: isUrdu),
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 20),

            // ── Stat pills ──────────────────────────────────────
            _StatRow(
              isUrdu: isUrdu,
              activeAlertsCount: _activeAlertsCount,
              onRefreshAlerts: _loadAlerts,
              temperature: _weatherTemp,
              cityName: _weatherCity,
            ),

            const SizedBox(height: 20),

            // ── Quick Actions ───────────────────────────────────
            _SectionLabel(title: isUrdu ? 'فوری رسائی' : 'Quick Access'),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.assessment_rounded,
                      label: isUrdu ? 'مارکیٹ\nجائزہ' : 'Market\nOverview',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.of(context).pushNamed(MyApp.marketOverviewRoute),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.cloud_rounded,
                      label: isUrdu ? 'موسم کی\nپیش گوئی' : 'Weather\nForecast',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.of(context).pushNamed(MyApp.weatherRoute),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickTile(
                      icon: Icons.bar_chart_rounded,
                      label: isUrdu ? 'تجزیاتی\nہب' : 'Analytics\nHub',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF7B1FA2)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      onTap: () => Navigator.of(context).pushNamed(MyApp.analyticsRoute),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── AI Advisory ─────────────────────────────────────
            _SectionLabel(title: isUrdu ? 'اے آئی مشورہ' : 'AI Advisory'),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AiAdvisoryCard(title: isUrdu ? 'اے آئی مشورہ' : 'AI Advisory'),
            ),

            const SizedBox(height: 24),

            // ── Today's Prices ──────────────────────────────────
            _SectionLabel(
              title: isUrdu ? "آج کی قیمتیں" : "Today's Prices",
              actionText: isUrdu ? 'سب دیکھیں' : 'View All',
              onAction: widget.onViewAllCrops,
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: svc.watchCrops(limit: 4, orderByField: 'updatedAt', descending: true),
              builder: (context, snap) {
                final cropsData = (snap.data?.isNotEmpty == true)
                    ? snap.data!
                    : fallbackCrops;
                final List<CropModel> crops = cropsData.map((c) => CropModel.fromMap(c)).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: crops.map((crop) {
                      final double price = crop.price;
                      final double prev  = crop.previousPrice;
                      final double pct   = prev == 0 ? 0
                          : ((price - prev) / prev * 100).abs();
                      return CropPriceTile(
                        emoji:         crop.imageEmoji,
                        name:          crop.name,
                        price:         price,
                        previousPrice: prev,
                        unit:          crop.unit,
                        trend:         crop.trend,
                        percentChange: crop.trend == 'stable' ? 0 : pct,
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Nearby Mandis ───────────────────────────────────
            _SectionLabel(
              title: isUrdu ? 'قریبی منڈیاں' : 'Nearby Mandis',
              actionText: isUrdu ? 'سب دیکھیں' : 'View All',
              onAction: widget.onViewAllMandis,
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: svc.watchMandis(), // Get all mandis, then sort, then take top 2
              builder: (context, snap) {
                final mandisData = (snap.data?.isNotEmpty == true)
                    ? snap.data!
                    : DummyData.mandis;
                
                List<MandiModel> mandiModels = mandisData.map((m) => MandiModel.fromMap(m)).toList();
                
                // If we have location, sort them
                if (_currentPosition != null) {
                  mandiModels = _locSvc.sortMandisByDistance(mandiModels, _currentPosition!);
                }
                
                // Take top 2
                final topMandis = mandiModels.take(2).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: topMandis.map((mandi) {
                      return MandiCard(
                        name:       mandi.name,
                        city:       mandi.city,
                        province:   mandi.province,
                        distance:   mandi.distance,
                        isOpen:     mandi.isOpen,
                        totalCrops: mandi.totalCrops,
                        onTap: () => Navigator.of(context).pushNamed(
                          MandiDetailScreen.routeName,
                          arguments: mandi,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Latest News ─────────────────────────────────────
            _SectionLabel(
              title: isUrdu ? 'تازہ ترین خبریں' : 'Latest News',
              actionText: isUrdu ? 'سب دیکھیں' : 'View All',
              onAction: () => Navigator.of(context).pushNamed(NewsScreen.routeName),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: _newsLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 2),
                    ),
                  )
                : Column(
                    children: (_homeNews.isNotEmpty ? _homeNews : _newsSvc.fallbackNews().take(2).toList())
                        .map((article) => NewsCard(
                          emoji:       article.emoji,
                          title:       article.title,
                          description: article.description,
                          date:        article.date,
                          category:    article.category,
                          onTap: () => Navigator.of(context).pushNamed(
                            NewsDetailScreen.routeName,
                            arguments: article.toMap(),
                          ),
                        ))
                        .toList(),
                  ),
            ),
          ]),
        ),
      ],
    );
  }
}

// ── Hero Header Delegate ──────────────────────────────────────────────────────
class _HeroHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const double _maxH = 180;
  static const double _minH = 88;
  
  final bool isUrdu;
  _HeroHeaderDelegate({required this.isUrdu});

  @override double get maxExtent => _maxH;
  @override double get minExtent => _minH;
  @override bool shouldRebuild(covariant _HeroHeaderDelegate old) => old.isUrdu != isUrdu;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double t = (shrinkOffset / (_maxH - _minH)).clamp(0.0, 1.0);

    return Stack(
      children: [
        // gradient bg
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_deep, _mid, Color(0xFF40916C)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // decorative circles
        Positioned(
          top: -30,
          right: -20,
          child: Opacity(
            opacity: (1 - t).clamp(0.0, 1.0),
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: -30,
          child: Opacity(
            opacity: (1 - t).clamp(0.0, 1.0),
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.08),
              ),
            ),
          ),
        ),

        // content
        Positioned(
          top: MediaQuery.paddingOf(context).top,
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: _lerp(12, 4, t),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // logo + text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (t < 0.6)
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseAuth.instance.currentUser?.uid != null
                              ? FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots()
                              : const Stream.empty(),
                          builder: (context, snap) {
                            final data = snap.data?.data() as Map<String, dynamic>?;
                            final name = data?['fullName'] ?? (isUrdu ? 'کسان' : 'Farmer');
                            return Text(
                              isUrdu ? 'اچھا دن، $name 👋' : 'Good day, $name 👋',
                              style: AppFonts.dmSans(context, 
                                color: Colors.white.withValues(alpha: 0.80),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      if (t < 0.6) const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Agri',
                              style: AppFonts.playfairDisplay(context, 
                                color: Colors.white,
                                fontSize: _lerp(28, 20, t),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: 'Pulse',
                              style: AppFonts.playfairDisplay(context, 
                                color: _accent,
                                fontSize: _lerp(28, 20, t),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (t < 0.4) ...[
                        const SizedBox(height: 4),
                        Text(
                          isUrdu ? 'مارکیٹ انٹیلیجنس' : 'MARKET INTELLIGENCE',
                          style: AppFonts.dmSans(context, 
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 9,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // actions
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () => Navigator.of(context).pushNamed(MyApp.notificationsRoute),
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: Colors.white, size: 24),
                  tooltip: 'Notifications',
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(ProfileScreen.routeName),
                  child: Container(
                     width: 36, height: 36,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: Colors.white.withValues(alpha: 0.15),
                       border: Border.all(
                         color: Colors.white.withValues(alpha: 0.35),
                         width: 1.5,
                       ),
                     ),
                     child: const Icon(Icons.person_rounded,
                         color: Colors.white, size: 20),
                   ),
                 ),
               ],
             ),
           ),
         ),
      ],
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

// ── Stat Row ──────────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final bool isUrdu;
  final int activeAlertsCount;
  final VoidCallback onRefreshAlerts;
  final String temperature;
  final String cityName;

  const _StatRow({
    required this.isUrdu,
    required this.activeAlertsCount,
    required this.onRefreshAlerts,
    required this.temperature,
    required this.cityName,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _StatCard(
            icon: Icons.storefront_rounded,
            value: '12',
            label: isUrdu ? "اوپن\nمارکیٹس" : "Open\nMarkets",
            iconColor: const Color(0xFF2D6A4F),
            bgColor: const Color(0xFFEBF5EC),
            onTap: () => Navigator.of(context).pushNamed(MandiListScreen.routeName),
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.trending_up_rounded,
            value: '+4.2%',
            label: isUrdu ? "گندم\nآج" : "Wheat\nToday",
            iconColor: const Color(0xFFF9A825),
            bgColor: const Color(0xFFFFF8E1),
            onTap: () {
              final wheatCrop = DummyData.crops.firstWhere(
                (c) => (c['name'] as String).toLowerCase() == 'wheat',
                orElse: () => DummyData.crops.first,
              );
              Navigator.of(context).pushNamed(
                CropDetailScreen.routeName,
                arguments: CropModel.fromMap(wheatCrop),
              );
            },
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.notifications_active_rounded,
            value: '$activeAlertsCount',
            label: isUrdu ? "پرائس\nالرٹس" : "Price\nAlerts",
            iconColor: const Color(0xFFE53935),
            bgColor: const Color(0xFFFFEBEE),
            onTap: () {
              Navigator.of(context).pushNamed(PriceAlertScreen.routeName).then((_) {
                onRefreshAlerts();
              });
            },
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.cloud_done_rounded,
            value: temperature,
            label: isUrdu ? "$cityName\nموسم" : "$cityName\nWeather",
            iconColor: const Color(0xFF1565C0),
            bgColor: const Color(0xFFE3F2FD),
            onTap: () => Navigator.of(context).pushNamed(MyApp.weatherRoute),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 106,
        padding: const EdgeInsets.all(10),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppFonts.dmSans(context, 
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
            ),
            Text(
              label,
              style: AppFonts.dmSans(context, 
                fontSize: 9.5,
                color: kTextLight,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Tile ────────────────────────────────────────────────────────────────
class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _QuickTile({
    required this.icon, required this.label,
    required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // subtle circle decoration
            Positioned(
              right: -12, bottom: -12,
              child: Container(
                width: 55, height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  Text(
                    label,
                    style: AppFonts.dmSans(context, 
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
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

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  const _SectionLabel({required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts.dmSans(context, 
                  color: kTextDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  actionText!,
                  style: AppFonts.dmSans(context, 
                    color: kPrimaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
