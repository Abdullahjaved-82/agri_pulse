import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/crop_model.dart';
import '../../models/mandi_model.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class MandiDetailScreen extends StatelessWidget {
  static const String routeName = '/mandi-detail';

  final MandiModel mandi;

  const MandiDetailScreen({super.key, required this.mandi});

  @override
  Widget build(BuildContext context) {
    final List<CropModel> mandiCrops = DummyData.crops
        .take(6)
        .map((crop) => CropModel.fromMap(crop))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(mandi.name),
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
          _HeaderCard(mandi: mandi),
          const SizedBox(height: 14),
          _MapPlaceholder(mandi: mandi),
          const SizedBox(height: 16),
          const Text(
            'Available Crops Today',
            style: TextStyle(
              color: kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...mandiCrops.map((crop) => _MandiCropTile(crop: crop)),
          const SizedBox(height: 10),
          const Text(
            'Contact Info',
            style: TextStyle(
              color: kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _ContactCard(mandi: mandi),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final MandiModel mandi;

  const _HeaderCard({required this.mandi});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = mandi.isOpen ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
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
        children: [
          Text(
            mandi.name,
            style: const TextStyle(
              color: kTextDark,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${mandi.city}, ${mandi.province}',
            style: const TextStyle(
              color: kTextLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mandi.isOpen ? 'Open Now' : 'Closed',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.access_time, color: kTextLight, size: 16),
              const SizedBox(width: 4),
              const Text(
                '6:00 AM - 2:00 PM',
                style: TextStyle(
                  color: kTextLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final MandiModel mandi;

  const _MapPlaceholder({required this.mandi});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kAccentColor.withValues(alpha: 0.45),
            kSecondaryColor.withValues(alpha: 0.22),
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.map,
              size: 64,
              color: kPrimaryColor.withValues(alpha: 0.8),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Text(
                'Map View',
                style: TextStyle(
                  color: kPrimaryColor.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place, size: 14, color: kPrimaryColor),
                  const SizedBox(width: 4),
                  Text(
                    mandi.city,
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
}

class _MandiCropTile extends StatelessWidget {
  final CropModel crop;

  const _MandiCropTile({required this.crop});

  @override
  Widget build(BuildContext context) {
    final Color trendColor;
    final String trendText;

    switch (crop.trend) {
      case 'up':
        trendColor = Colors.green;
        trendText = 'Up';
        break;
      case 'down':
        trendColor = Colors.red;
        trendText = 'Down';
        break;
      default:
        trendColor = Colors.amber.shade700;
        trendText = 'Stable';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Text(crop.imageEmoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop.name,
                  style: const TextStyle(
                    color: kTextDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  crop.urduName,
                  style: const TextStyle(
                    color: kTextLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PKR ${crop.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                trendText,
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
    );
  }
}

class _ContactCard extends StatelessWidget {
  final MandiModel mandi;

  const _ContactCard({required this.mandi});

  String _phoneForMandi(int id) {
    const List<String> phones = [
      '+92 42 111 222 101',
      '+92 41 111 222 202',
      '+92 61 111 222 303',
      '+92 21 111 222 404',
      '+92 91 111 222 505',
      '+92 51 111 222 606',
    ];
    return phones[(id - 1) % phones.length];
  }

  String _addressForMandi() {
    return '${mandi.name}, ${mandi.city}, ${mandi.province}, Pakistan';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ContactTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            value: _phoneForMandi(mandi.id),
          ),
          const SizedBox(height: 12),
          _ContactTile(
            icon: Icons.location_on_outlined,
            title: 'Address',
            value: _addressForMandi(),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: kAccentColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: kPrimaryColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kTextLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: kTextDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

