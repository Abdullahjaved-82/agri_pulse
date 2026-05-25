import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class AnalyticsScreen extends StatefulWidget {
  static const String routeName = '/analytics';

  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const List<String> _timeFilters = ['7 Days', '30 Days'];
  int _activeFilterIndex = 0; // 0 = 7 days, 1 = 30 days
  String _selectedCrop = 'Wheat';
  bool _isLoadingChart = false;

  late List<String> _cropOptions;

  @override
  void initState() {
    super.initState();
    _cropOptions = DummyData.crops.map((c) => c['name'] as String).toList();
    if (!_cropOptions.contains(_selectedCrop) && _cropOptions.isNotEmpty) {
      _selectedCrop = _cropOptions.first;
    }
  }

  void _onFilterChanged(int index) {
    if (_activeFilterIndex == index) return;
    setState(() {
      _activeFilterIndex = index;
      _isLoadingChart = true;
    });
    
    // Simulate loading for skeleton effect
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoadingChart = false);
    });
  }

  void _onCropChanged(String? crop) {
    if (crop == null || crop == _selectedCrop) return;
    setState(() {
      _selectedCrop = crop;
      _isLoadingChart = true;
    });
    
    // Simulate loading for skeleton effect
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoadingChart = false);
    });
  }

  List<Map<String, dynamic>> get _cropHistory {
    final history7d = DummyData.historyForCrop(_selectedCrop, fallbackPrice: 3000);
    if (_activeFilterIndex == 0) {
      return history7d;
    }
    
    // Generate synthetic 30-day data
    return List.generate(30, (i) {
      if (i >= 23 && history7d.length == 7) {
        return history7d[i - 23];
      }
      final double volatility = (math.Random().nextDouble() - 0.5) * 50;
      final double basePrice = (history7d.isNotEmpty ? history7d.first['price'] as num : 3000).toDouble();
      return {
        'date': DateTime.now().subtract(Duration(days: 30 - i)).toIso8601String(),
        'price': basePrice + volatility,
      };
    });
  }

  List<Map<String, dynamic>> get _topCropPrices {
    final List<Map<String, dynamic>> crops = List<Map<String, dynamic>>.from(
      DummyData.crops,
    );
    crops.sort((a, b) {
      final double aPrice = (a['price'] as num).toDouble();
      final double bPrice = (b['price'] as num).toDouble();
      return bPrice.compareTo(aPrice);
    });
    return crops.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Analytics'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          kDefaultPadding,
          14,
          kDefaultPadding,
          20,
        ),
        children: [
          _buildFilterTabs(),
          const SizedBox(height: 18),
          _buildPriceTrendSection(),
          const SizedBox(height: 18),
          _buildCropComparisonSection(),
          const SizedBox(height: 18),
          _buildSummaryGrid(),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: List.generate(_timeFilters.length, (index) {
        final bool isActive = _activeFilterIndex == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == _timeFilters.length - 1 ? 0 : 8),
            child: InkWell(
              onTap: () => _onFilterChanged(index),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? kPrimaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? kPrimaryColor : kTextLight.withValues(alpha: 0.35),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _timeFilters[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : kTextDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPriceTrendSection() {
    final history = _cropHistory;
    final List<FlSpot> spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), (entry.value['price'] as num).toDouble());
    }).toList();

    final List<double> prices =
        history.map((e) => (e['price'] as num).toDouble()).toList();
    final double minPrice = prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
    final double maxPrice = prices.isEmpty ? 100 : prices.reduce((a, b) => a > b ? a : b);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Trend',
                style: TextStyle(
                  color: kTextDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCrop,
                  items: _cropOptions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                  onChanged: _onCropChanged,
                  icon: const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: _isLoadingChart
                ? _buildSkeletonChart()
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (spots.length - 1).toDouble(),
                      minY: minPrice - (maxPrice - minPrice) * 0.1,
                      maxY: maxPrice + (maxPrice - minPrice) * 0.1,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: kTextLight.withValues(alpha: 0.22),
                            strokeWidth: 1,
                            dashArray: const [4, 4],
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _activeFilterIndex == 1 ? 5 : 1, // Skip labels for 30 days
                            getTitlesWidget: (value, meta) {
                              final int index = value.toInt();
                              if (index < 0 || index >= history.length) {
                                return const SizedBox.shrink();
                              }
                              final DateTime day = DateTime.parse(history[index]['date'] as String);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _activeFilterIndex == 1 ? '${day.day}/${day.month}' : _shortWeekDay(day.weekday),
                                  style: const TextStyle(color: kTextLight, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 3,
                          color: kSecondaryColor,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                kAccentColor.withValues(alpha: 0.45),
                                kAccentColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                          dotData: FlDotData(
                            show: _activeFilterIndex == 0, // Only show dots for 7 days
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: kSecondaryColor,
                              );
                            },
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

  Widget _buildSkeletonChart() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: kSecondaryColor),
      ),
    );
  }

  Widget _buildCropComparisonSection() {
    final List<Map<String, dynamic>> crops = _topCropPrices;
    final double maxY = crops
            .map((crop) => (crop['price'] as num).toDouble())
            .reduce((a, b) => a > b ? a : b) +
        600;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Crops by Price',
            style: TextStyle(
              color: kTextDark,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: kTextLight.withValues(alpha: 0.16),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();
                        if (index < 0 || index >= crops.length) {
                          return const SizedBox.shrink();
                        }

                        final String name = crops[index]['name'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            name.length > 6 ? name.substring(0, 6) : name,
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
                barGroups: crops.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final double price = (entry.value['price'] as num).toDouble();

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: price,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        color: index.isEven ? kPrimaryColor : kSecondaryColor,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: const [
        _SummaryCard(
          icon: Icons.trending_up,
          iconColor: kPrimaryColor,
          value: 'Cotton 8,400 PKR',
          label: 'Highest Price Today',
        ),
        _SummaryCard(
          icon: Icons.trending_down,
          iconColor: Colors.red,
          value: 'Wheat 3,200 PKR',
          label: 'Lowest Price Today',
        ),
        _SummaryCard(
          icon: Icons.local_shipping,
          iconColor: Colors.blue,
          value: 'Rice',
          label: 'Most Traded',
        ),
        _SummaryCard(
          icon: Icons.bolt,
          iconColor: kHighlightColor,
          value: 'Tomato +8.2%',
          label: 'Biggest Rise',
        ),
      ],
    );
  }

  String _shortWeekDay(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: kTextDark,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: kTextLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

