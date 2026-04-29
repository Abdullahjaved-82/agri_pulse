import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/constants.dart';

class WeatherScreen extends StatelessWidget {
  static const String routeName = '/weather';

  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> weekForecast = [
      {'day': 'Mon', 'temp': '33 C', 'condition': 'Sunny'},
      {'day': 'Tue', 'temp': '31 C', 'condition': 'Partly Cloudy'},
      {'day': 'Wed', 'temp': '29 C', 'condition': 'Light Rain'},
      {'day': 'Thu', 'temp': '30 C', 'condition': 'Windy'},
      {'day': 'Fri', 'temp': '34 C', 'condition': 'Sunny'},
      {'day': 'Sat', 'temp': '35 C', 'condition': 'Hot'},
      {'day': 'Sun', 'temp': '32 C', 'condition': 'Cloudy'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Advisory'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kAccentColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tip: For wheat and maize, early morning irrigation is recommended during warmer days this week.',
              style: TextStyle(fontWeight: FontWeight.w600, color: kTextDark),
            ),
          ),
          const SizedBox(height: 12),
          ...weekForecast.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.wb_sunny_outlined, color: kPrimaryColor),
                title: Text(
                  '${item['day']} - ${item['temp']}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(item['condition'] ?? ''),
              ),
            );
          }),
        ],
      ),
    );
  }
}

