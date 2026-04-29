final List<Map<String, dynamic>> dummyCrops = [
  {
    'id': 1,
    'name': 'Wheat',
    'urduName': 'گندم',
    'price': 3215.0,
    'previousPrice': 3180.0,
    'trend': 'up',
    'category': 'Grain',
    'imageEmoji': '🌾',
    'unit': 'PKR/40kg',
  },
  {
    'id': 2,
    'name': 'Rice',
    'urduName': 'چاول',
    'price': 4680.0,
    'previousPrice': 4710.0,
    'trend': 'down',
    'category': 'Grain',
    'imageEmoji': '🍚',
    'unit': 'PKR/40kg',
  },
  {
    'id': 3,
    'name': 'Cotton',
    'urduName': 'کپاس',
    'price': 8120.0,
    'previousPrice': 8050.0,
    'trend': 'up',
    'category': 'Cash Crop',
    'imageEmoji': '🧵',
    'unit': 'PKR/40kg',
  },
  {
    'id': 4,
    'name': 'Sugarcane',
    'urduName': 'گنا',
    'price': 1425.0,
    'previousPrice': 1425.0,
    'trend': 'stable',
    'category': 'Cash Crop',
    'imageEmoji': '🎋',
    'unit': 'PKR/40kg',
  },
  {
    'id': 5,
    'name': 'Maize',
    'urduName': 'مکئی',
    'price': 2895.0,
    'previousPrice': 2840.0,
    'trend': 'up',
    'category': 'Grain',
    'imageEmoji': '🌽',
    'unit': 'PKR/40kg',
  },
  {
    'id': 6,
    'name': 'Onion',
    'urduName': 'پیاز',
    'price': 2360.0,
    'previousPrice': 2440.0,
    'trend': 'down',
    'category': 'Vegetable',
    'imageEmoji': '🧅',
    'unit': 'PKR/40kg',
  },
  {
    'id': 7,
    'name': 'Tomato',
    'urduName': 'ٹماٹر',
    'price': 2650.0,
    'previousPrice': 2620.0,
    'trend': 'up',
    'category': 'Vegetable',
    'imageEmoji': '🍅',
    'unit': 'PKR/40kg',
  },
  {
    'id': 8,
    'name': 'Potato',
    'urduName': 'آلو',
    'price': 1985.0,
    'previousPrice': 1990.0,
    'trend': 'stable',
    'category': 'Vegetable',
    'imageEmoji': '🥔',
    'unit': 'PKR/40kg',
  },
];

final List<Map<String, dynamic>> dummyMandis = [
  {
    'id': 1,
    'name': 'Badami Bagh Mandi',
    'city': 'Lahore',
    'province': 'Punjab',
    'distance': '12 km',
    'isOpen': true,
    'totalCrops': 62,
  },
  {
    'id': 2,
    'name': 'Jhang Road Grain Market',
    'city': 'Faisalabad',
    'province': 'Punjab',
    'distance': '28 km',
    'isOpen': true,
    'totalCrops': 54,
  },
  {
    'id': 3,
    'name': 'Hasilpur Wholesale Mandi',
    'city': 'Multan',
    'province': 'Punjab',
    'distance': '35 km',
    'isOpen': true,
    'totalCrops': 47,
  },
  {
    'id': 4,
    'name': 'Super Highway Sabzi Mandi',
    'city': 'Karachi',
    'province': 'Sindh',
    'distance': '18 km',
    'isOpen': false,
    'totalCrops': 71,
  },
  {
    'id': 5,
    'name': 'Hashtnagri Mandi',
    'city': 'Peshawar',
    'province': 'Khyber Pakhtunkhwa',
    'distance': '22 km',
    'isOpen': true,
    'totalCrops': 39,
  },
  {
    'id': 6,
    'name': 'Pir Wadhai Fruit and Vegetable Market',
    'city': 'Rawalpindi',
    'province': 'Punjab',
    'distance': '16 km',
    'isOpen': true,
    'totalCrops': 58,
  },
];

final List<Map<String, dynamic>> dummyNews = [
  {
    'id': 1,
    'title': 'Punjab wheat arrivals increase after weekend rains',
    'description':
        'Improved soil moisture has boosted late wheat arrivals in central Punjab, with mandi activity rising in Lahore and Faisalabad.',
    'date': '2026-03-26',
    'category': 'Market Update',
    'emoji': '📈',
  },
  {
    'id': 2,
    'title': 'Rice exporters expect stable April demand',
    'description':
        'Traders report steady inquiry from Gulf buyers, helping support medium-grain rice prices in southern markets.',
    'date': '2026-03-25',
    'category': 'Export',
    'emoji': '🚢',
  },
  {
    'id': 3,
    'title': 'Cotton ginning slows as energy costs rise',
    'description':
        'Several ginning units in south Punjab are operating shorter shifts, adding near-term pressure to cotton procurement rates.',
    'date': '2026-03-24',
    'category': 'Crop Supply',
    'emoji': '🏭',
  },
  {
    'id': 4,
    'title': 'Tomato prices soften in Karachi wholesale market',
    'description':
        'Higher truck arrivals from interior Sindh have eased tomato prices, while retailers expect short-term volatility.',
    'date': '2026-03-23',
    'category': 'Vegetables',
    'emoji': '🍅',
  },
  {
    'id': 5,
    'title': 'Water advisory issued for early maize growers',
    'description':
        'Agriculture extension teams advise staggered irrigation in canal-fed districts to protect early maize yield potential.',
    'date': '2026-03-22',
    'category': 'Advisory',
    'emoji': '💧',
  },
];

final Map<String, List<Map<String, dynamic>>> cropPriceHistory = {
  'Wheat': [
    {'date': '2026-03-20', 'price': 3175.0},
    {'date': '2026-03-21', 'price': 3190.0},
    {'date': '2026-03-22', 'price': 3220.0},
    {'date': '2026-03-23', 'price': 3205.0},
    {'date': '2026-03-24', 'price': 3235.0},
    {'date': '2026-03-25', 'price': 3180.0},
    {'date': '2026-03-26', 'price': 3215.0},
  ],
  'Rice': [
    {'date': '2026-03-20', 'price': 4740.0},
    {'date': '2026-03-21', 'price': 4720.0},
    {'date': '2026-03-22', 'price': 4695.0},
    {'date': '2026-03-23', 'price': 4705.0},
    {'date': '2026-03-24', 'price': 4688.0},
    {'date': '2026-03-25', 'price': 4710.0},
    {'date': '2026-03-26', 'price': 4680.0},
  ],
  'Cotton': [
    {'date': '2026-03-20', 'price': 7990.0},
    {'date': '2026-03-21', 'price': 8040.0},
    {'date': '2026-03-22', 'price': 8075.0},
    {'date': '2026-03-23', 'price': 8035.0},
    {'date': '2026-03-24', 'price': 8095.0},
    {'date': '2026-03-25', 'price': 8050.0},
    {'date': '2026-03-26', 'price': 8120.0},
  ],
  'Sugarcane': [
    {'date': '2026-03-20', 'price': 1410.0},
    {'date': '2026-03-21', 'price': 1420.0},
    {'date': '2026-03-22', 'price': 1430.0},
    {'date': '2026-03-23', 'price': 1422.0},
    {'date': '2026-03-24', 'price': 1428.0},
    {'date': '2026-03-25', 'price': 1425.0},
    {'date': '2026-03-26', 'price': 1425.0},
  ],
  'Maize': [
    {'date': '2026-03-20', 'price': 2815.0},
    {'date': '2026-03-21', 'price': 2830.0},
    {'date': '2026-03-22', 'price': 2860.0},
    {'date': '2026-03-23', 'price': 2850.0},
    {'date': '2026-03-24', 'price': 2885.0},
    {'date': '2026-03-25', 'price': 2840.0},
    {'date': '2026-03-26', 'price': 2895.0},
  ],
  'Onion': [
    {'date': '2026-03-20', 'price': 2475.0},
    {'date': '2026-03-21', 'price': 2450.0},
    {'date': '2026-03-22', 'price': 2435.0},
    {'date': '2026-03-23', 'price': 2410.0},
    {'date': '2026-03-24', 'price': 2395.0},
    {'date': '2026-03-25', 'price': 2440.0},
    {'date': '2026-03-26', 'price': 2360.0},
  ],
  'Tomato': [
    {'date': '2026-03-20', 'price': 2575.0},
    {'date': '2026-03-21', 'price': 2605.0},
    {'date': '2026-03-22', 'price': 2588.0},
    {'date': '2026-03-23', 'price': 2615.0},
    {'date': '2026-03-24', 'price': 2640.0},
    {'date': '2026-03-25', 'price': 2620.0},
    {'date': '2026-03-26', 'price': 2650.0},
  ],
  'Potato': [
    {'date': '2026-03-20', 'price': 1978.0},
    {'date': '2026-03-21', 'price': 1992.0},
    {'date': '2026-03-22', 'price': 1987.0},
    {'date': '2026-03-23', 'price': 1996.0},
    {'date': '2026-03-24', 'price': 2002.0},
    {'date': '2026-03-25', 'price': 1990.0},
    {'date': '2026-03-26', 'price': 1985.0},
  ],
};

class DummyData {
  static const List<double> _fallbackMultipliers = [
    0.985,
    0.993,
    1.004,
    0.997,
    1.008,
    0.999,
    1.012,
  ];

  static List<Map<String, dynamic>> get crops => dummyCrops;

  static List<Map<String, dynamic>> get mandis => dummyMandis;

  static List<Map<String, dynamic>> get news => dummyNews;

  static List<Map<String, dynamic>> get wheatHistory =>
      cropPriceHistory['Wheat'] ?? const [];

  static List<Map<String, dynamic>> historyForCrop(
    String cropName, {
    double? fallbackPrice,
  }) {
    final List<Map<String, dynamic>>? history = cropPriceHistory[cropName];
    if (history != null && history.isNotEmpty) {
      return history;
    }

    if (fallbackPrice == null) {
      return const [];
    }

    final DateTime startDate = DateTime(2026, 3, 20);
    return List.generate(_fallbackMultipliers.length, (index) {
      return {
        'date': startDate.add(Duration(days: index)).toIso8601String(),
        'price': fallbackPrice * _fallbackMultipliers[index],
      };
    });
  }
}
