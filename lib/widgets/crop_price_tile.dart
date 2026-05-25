import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CropPriceTile extends StatelessWidget {
  final String emoji;
  final String name;
  final double price;
  final double? previousPrice;
  final String unit;
  final String trend;
  final double percentChange;

  const CropPriceTile({
    super.key,
    required this.emoji,
    required this.name,
    required this.price,
    required this.unit,
    required this.trend,
    required this.percentChange,
    this.previousPrice,
  });

  @override
  Widget build(BuildContext context) {
    final Color trendColor;
    final IconData trendIcon;
    final String trendIndicator;

    switch (trend) {
      case 'up':
        trendColor = Colors.green.shade600;
        trendIcon = Icons.arrow_upward_rounded;
        trendIndicator = '🟢';
        break;
      case 'down':
        trendColor = Colors.red.shade600;
        trendIcon = Icons.arrow_downward_rounded;
        trendIndicator = '🔴';
        break;
      default:
        trendColor = Colors.amber.shade700;
        trendIcon = Icons.remove_rounded;
        trendIndicator = '⚪';
    }

    final double prevP = previousPrice ?? price;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: kTextDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$trendIndicator Old: ${prevP.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: kTextLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(' → ', style: TextStyle(color: kTextLight, fontSize: 11)),
                    Text(
                      'New: ${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: trendColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PKR ${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(trendIcon, color: trendColor, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    trend == 'stable'
                        ? '0.0%'
                        : '${trend == 'up' ? '+' : '-'}${percentChange.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
