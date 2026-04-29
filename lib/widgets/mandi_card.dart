import 'package:flutter/material.dart';

import '../utils/colors.dart';

class MandiCard extends StatelessWidget {
  final String name;
  final String city;
  final String distance;
  final bool isOpen;
  final String? province;
  final int? totalCrops;
  final VoidCallback? onTap;

  const MandiCard({
    super.key,
    required this.name,
    required this.city,
    required this.distance,
    required this.isOpen,
    this.province,
    this.totalCrops,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = isOpen ? Colors.green : Colors.red;

    final Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: kTextDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      province == null ? city : '$city, $province',
                      style: const TextStyle(
                        color: kTextLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: kTextLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$distance away',
                          style: const TextStyle(
                            color: kTextLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (totalCrops != null) ...[
            const SizedBox(height: 12),
            Text(
              '$totalCrops Crops Available',
              style: const TextStyle(
                color: kPrimaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return cardContent;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: cardContent,
    );
  }
}

