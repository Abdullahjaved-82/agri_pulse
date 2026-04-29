import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/crop_model.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class CropDetailScreen extends StatelessWidget {
  static const String routeName = '/crop-detail';

  final CropModel crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> priceHistory = DummyData.historyForCrop(
      crop.name,
      fallbackPrice: crop.price,
    );
    final List<double> values = priceHistory
        .map((entry) => (entry['price'] as num).toDouble())
        .toList();

    final double dayHigh = values.reduce(math.max);
    final double dayLow = values.reduce(math.min);
    final double avg7Day = values.reduce((a, b) => a + b) / values.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(crop.name),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                    title: "Today's High",
                    value: 'PKR ${dayHigh.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    title: "Today's Low",
                    value: 'PKR ${dayLow.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    title: '7-Day Avg',
                    value: 'PKR ${avg7Day.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
                  const Text(
                    'Price History (7 Days)',
                    style: TextStyle(
                      color: kTextDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        minY: dayLow - 30,
                        maxY: dayHigh + 30,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 20,
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
                              reservedSize: 44,
                              interval: 20,
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
                                if (index < 0 || index >= priceHistory.length) {
                                  return const SizedBox.shrink();
                                }
                                final DateTime date = DateTime.parse(
                                  priceHistory[index]['date'] as String,
                                );
                                final String label = _weekdayLabel(date);
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
                            spots: List.generate(priceHistory.length, (index) {
                              final double value =
                                  (priceHistory[index]['price'] as num)
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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alert set successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              ),
            ),
            child: const Text(
              'Set Price Alert',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
