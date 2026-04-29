import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CropPriceTile extends StatelessWidget {
  final String emoji;
  final String name;
  final double price;
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
  });

  @override
  Widget build(BuildContext context) {
    final IconData trendIcon;
    final Color trendColor;

    switch (trend) {
      case 'up':
        trendIcon = Icons.arrow_upward;
        trendColor = Colors.green;
        break;
      case 'down':
        trendIcon = Icons.arrow_downward;
        trendColor = Colors.red;
        break;
      default:
        trendIcon = Icons.arrow_forward;
        trendColor = Colors.amber.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: kTextDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PKR ${price.toStringAsFixed(0)} • $unit',
                  style: const TextStyle(color: kTextLight, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(trendIcon, color: trendColor, size: 18),
              const SizedBox(width: 3),
              Text(
                '${percentChange.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: trendColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
