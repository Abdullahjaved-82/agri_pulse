import 'package:flutter/material.dart';

import '../models/crop_model.dart';
import '../utils/colors.dart';

class CropCard extends StatelessWidget {
  final CropModel crop;
  final VoidCallback? onTap;

  const CropCard({super.key, required this.crop, this.onTap});

  @override
  Widget build(BuildContext context) {
    final _TrendUi trendUi = _trendToUi(crop.trend);
    final double delta = crop.previousPrice == 0
        ? 0
        : ((crop.price - crop.previousPrice) / crop.previousPrice * 100).abs();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: kAccentColor.withValues(alpha: 0.34),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Hero(
                    tag: 'crop-hero-${crop.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        crop.imageEmoji,
                        style: const TextStyle(fontSize: 42),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                crop.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PKR ${crop.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: trendUi.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${trendUi.symbol} ${delta.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: trendUi.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TrendUi _trendToUi(String trend) {
    switch (trend) {
      case 'up':
        return const _TrendUi(symbol: '↑', color: Colors.green);
      case 'down':
        return const _TrendUi(symbol: '↓', color: Colors.red);
      default:
        return _TrendUi(symbol: '→', color: Colors.amber.shade800);
    }
  }
}

class _TrendUi {
  final String symbol;
  final Color color;

  const _TrendUi({required this.symbol, required this.color});
}
