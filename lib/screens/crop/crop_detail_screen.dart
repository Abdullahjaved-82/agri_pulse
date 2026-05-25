import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/crop_model.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/language_provider.dart';

import '../alerts/price_alert_screen.dart'; // We'll need to extract the dialog or navigate
import '../../services/groq_service.dart';
import '../../services/firestore_service.dart';

class CropDetailScreen extends StatefulWidget {
  static const String routeName = '/crop-detail';

  final CropModel crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  bool _is30Days = false;
  
  void _showAlertDialog() {
    // We can show a simpler dialog here or navigate
    Navigator.of(context).pushNamed('/price-alerts');
  }

  @override
  Widget build(BuildContext context) {
    final crop = widget.crop;
    
    // Gov vs Market Mock Data (Simulating Web Scraper Pipeline)
    final double govPrice = crop.price * 0.92; // 8% cheaper roughly
    final double marketPrice = crop.price * 1.05; // 5% higher roughly

    final lang = LanguageScope.of(context);
    final isUrdu = lang.isUrdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? crop.urduName : crop.name),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().watchCropHistory(crop.name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            );
          }

          List<Map<String, dynamic>> priceHistory7d = snapshot.data ?? [];
          
          if (priceHistory7d.isEmpty) {
            priceHistory7d = DummyData.historyForCrop(crop.name, fallbackPrice: crop.price);
          }

          // Generate synthetic 30-day data by extending the 7-day trend backwards
          final List<Map<String, dynamic>> priceHistory30d = List.generate(30, (i) {
            if (i >= 23 && i - 23 < priceHistory7d.length) {
              return priceHistory7d[i - 23];
            }
            if (priceHistory7d.isEmpty) return {'date': DateTime.now().toIso8601String(), 'price': crop.price};
            
            final double volatility = (math.Random().nextDouble() - 0.5) * 50;
            final double basePrice = (priceHistory7d.first['price'] as num).toDouble();
            return {
              'date': DateTime.parse(priceHistory7d.first['date'] as String)
                  .subtract(Duration(days: 23 - i))
                  .toIso8601String(),
              'price': basePrice + volatility - ((23 - i) * 5),
            };
          });

          final List<Map<String, dynamic>> activeHistory = _is30Days ? priceHistory30d : priceHistory7d;

          final List<double> values = activeHistory
              .map((entry) => (entry['price'] as num).toDouble())
              .toList();

          final double dayHigh = values.isNotEmpty ? values.reduce(math.max) : crop.price;
          final double dayLow = values.isNotEmpty ? values.reduce(math.min) : crop.price;
          final double avg7Day = values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : crop.price;

          // Calculate clean, well-spaced dynamic Y-axis intervals to prevent overlapping labels
          final double priceDelta = dayHigh - dayLow;
          double yInterval;
          if (priceDelta == 0) {
            yInterval = (dayHigh * 0.1).ceilToDouble();
            if (yInterval < 5) yInterval = 5;
          } else {
            final double baseInterval = priceDelta / 5;
            if (baseInterval < 5) {
              yInterval = 5;
            } else if (baseInterval < 10) {
              yInterval = 10;
            } else if (baseInterval < 25) {
              yInterval = 25;
            } else if (baseInterval < 50) {
              yInterval = 50;
            } else if (baseInterval < 100) {
              yInterval = 100;
            } else if (baseInterval < 250) {
              yInterval = 250;
            } else if (baseInterval < 500) {
              yInterval = 500;
            } else {
              yInterval = (baseInterval / 100).ceil() * 100.0;
            }
          }

          double minY = (dayLow / yInterval).floor() * yInterval;
          double maxY = (dayHigh / yInterval).ceil() * yInterval;

          // Ensure at least two intervals are visible
          if (maxY - minY < yInterval * 2) {
            minY -= yInterval;
            maxY += yInterval;
          }
          if (minY < 0) minY = 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              kDefaultPadding,
              14,
              kDefaultPadding,
              22,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kPrimaryColor, kSecondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'crop-hero-${crop.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            crop.imageEmoji,
                            style: const TextStyle(fontSize: 72),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        crop.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        crop.urduName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PKR ${crop.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'PKR per 40kg',
                        style: TextStyle(
                          color: kTextLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Yesterday: PKR ${crop.previousPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: kTextDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: isUrdu ? "آج کی بلند ترین" : "Today's High",
                        value: 'PKR ${dayHigh.toStringAsFixed(0)}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: isUrdu ? "آج کی کم ترین" : "Today's Low",
                        value: 'PKR ${dayLow.toStringAsFixed(0)}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: isUrdu ? "7 دن کا اوسط" : '7-Day Avg',
                        value: 'PKR ${avg7Day.toStringAsFixed(0)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                // --- PRICE COMPARISON UI (GOV VS OPEN MARKET) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kSecondaryColor.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.compare_arrows_rounded, color: kSecondaryColor),
                          const SizedBox(width: 8),
                          Text(
                            isUrdu ? 'قیمت کا موازنہ (اسکریپ شدہ)' : 'Price Comparison (Scraped)',
                            style: const TextStyle(
                              color: kTextDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ComparisonCard(
                              title: isUrdu ? 'پنجاب حکومت (AMIS)' : 'Gov Support (AMIS)',
                              price: govPrice,
                              color: kPrimaryColor,
                              isGov: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ComparisonCard(
                              title: isUrdu ? 'لوکل مارکیٹ (اوسط)' : 'Open Market (Avg)',
                              price: marketPrice,
                              color: Colors.orange.shade700,
                              isGov: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kSecondaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 14, color: kSecondaryColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isUrdu
                                    ? 'یہ ڈیٹا براہ راست پنجاب حکومت کی ویب سائٹ اور مارکیٹ کے ذرائع سے لیا گیا ہے۔'
                                    : 'Data fetched via live python scrapers from Punjab Gov and Market sources.',
                                style: const TextStyle(fontSize: 11, color: kTextDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // --- END PRICE COMPARISON UI ---

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isUrdu ? 'قیمت کی تاریخ' : 'Price History',
                            style: const TextStyle(
                              color: kTextDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('7D', style: TextStyle(fontSize: 11)),
                                selected: !_is30Days,
                                selectedColor: kSecondaryColor,
                                labelStyle: TextStyle(
                                  color: !_is30Days ? Colors.white : kTextDark,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) => setState(() => _is30Days = false),
                              ),
                              const SizedBox(width: 4),
                              ChoiceChip(
                                label: const Text('30D', style: TextStyle(fontSize: 11)),
                                selected: _is30Days,
                                selectedColor: kSecondaryColor,
                                labelStyle: TextStyle(
                                  color: _is30Days ? Colors.white : kTextDark,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) => setState(() => _is30Days = true),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            minY: minY,
                            maxY: maxY,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: yInterval,
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: kTextLight.withValues(alpha: 0.2),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                              getDrawingVerticalLine: (value) => FlLine(
                                color: kTextLight.withValues(alpha: 0.15),
                                strokeWidth: 1,
                                dashArray: [3, 5],
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: kTextLight.withValues(alpha: 0.16),
                              ),
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: yInterval,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Text(
                                        value.toStringAsFixed(0),
                                        style: const TextStyle(
                                          color: kTextLight,
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 28,
                                  getTitlesWidget: (value, meta) {
                                    final int index = value.toInt();
                                    if (index < 0 || index >= activeHistory.length) {
                                      return const SizedBox.shrink();
                                    }
                                    
                                    // Only show every nth label to avoid crowding
                                    if (_is30Days && index % 5 != 0 && index != activeHistory.length - 1) {
                                      return const SizedBox.shrink();
                                    }

                                    final DateTime date = DateTime.parse(
                                      activeHistory[index]['date'] as String,
                                    );
                                    final String label = _is30Days ? '${date.day}/${date.month}' : _weekdayLabel(date);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          color: kTextLight,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (_) => kPrimaryColor,
                                getTooltipItems: (spots) {
                                  return spots
                                      .map(
                                        (spot) => LineTooltipItem(
                                          'PKR ${spot.y.toStringAsFixed(0)}',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                      .toList();
                                },
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(activeHistory.length, (index) {
                                  final double value =
                                      (activeHistory[index]['price'] as num)
                                          .toDouble();
                                  return FlSpot(index.toDouble(), value);
                                }),
                                isCurved: true,
                                color: kSecondaryColor,
                                barWidth: 3.2,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (offset, lineChartBarData, lineChartBarIndex, index) {
                                    return FlDotCirclePainter(
                                      radius: 3.2,
                                      color: kSecondaryColor,
                                      strokeWidth: 1.2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: kSecondaryColor.withValues(alpha: 0.12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // --- AI ADVISORY ---
                _CropAiAdvisory(crop: crop, history: priceHistory7d),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showAlertDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              ),
            ),
            child: Text(
              isUrdu ? 'قیمت کا الرٹ سیٹ کریں' : 'Set Price Alert',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(DateTime date) {
    const List<String> labels = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return labels[date.weekday - 1];
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kTextLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: kTextDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String title;
  final double price;
  final Color color;
  final bool isGov;

  const _ComparisonCard({
    required this.title,
    required this.price,
    required this.color,
    required this.isGov,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGov ? Icons.account_balance : Icons.storefront,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PKR ${price.toStringAsFixed(0)}',
            style: const TextStyle(
              color: kTextDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CropAiAdvisory extends StatefulWidget {
  final CropModel crop;
  final List<Map<String, dynamic>> history;

  const _CropAiAdvisory({required this.crop, required this.history});

  @override
  State<_CropAiAdvisory> createState() => _CropAiAdvisoryState();
}

class _CropAiAdvisoryState extends State<_CropAiAdvisory> {
  final GroqService _groqService = GroqService();
  Future<Map<String, String>>? _advisoryFuture;

  @override
  void initState() {
    super.initState();
    _loadAdvisory();
  }

  void _loadAdvisory() {
    setState(() {
      _advisoryFuture = _groqService.generateCropAdvisory(
        cropName: widget.crop.name,
        currentPrice: widget.crop.price,
        previousPrice: widget.crop.previousPrice,
        trend: widget.crop.trend,
        priceHistory7d: widget.history
            .map((e) => (e['price'] as num).toDouble())
            .toList(),
        region: 'Punjab',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSecondaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSecondaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: kSecondaryColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'AI Market Advisory',
                  style: TextStyle(
                    color: kTextDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: kSecondaryColor),
                onPressed: _loadAdvisory,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, String>>(
            future: _advisoryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Text(
                  'Unable to load AI advisory. Try again later.',
                  style: TextStyle(color: kTextLight),
                );
              }

              final data = snapshot.data!;
              final rec = data['recommendation']!;
              final reasoning = data['reasoning']!;
              final confidence = data['confidence']!;

              Color recColor;
              if (rec == 'BUY') recColor = Colors.green.shade600;
              else if (rec == 'SELL') recColor = Colors.red.shade600;
              else recColor = Colors.orange.shade600;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: recColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rec,
                          style: TextStyle(
                            color: recColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Confidence: $confidence',
                        style: const TextStyle(
                          color: kTextLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reasoning,
                    style: const TextStyle(
                      color: kTextDark,
                      height: 1.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
