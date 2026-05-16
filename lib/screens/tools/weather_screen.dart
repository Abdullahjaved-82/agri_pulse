import 'package:flutter/material.dart';

import '../../models/weather_model.dart';
import '../../services/weather_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class WeatherScreen extends StatefulWidget {
  static const String routeName = '/weather';

  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final List<String> _cities = const [
    'Lahore',
    'Islamabad',
    'Faisalabad',
    'Bahawalpur',
    'Multan',
    'Rawalpindi',
    'Peshawar',
    'Karachi',
    'Quetta',
  ];

  late Future<WeatherReport> _forecastFuture;
  String _selectedCity = 'Lahore';

  @override
  void initState() {
    super.initState();
    _forecastFuture = _weatherService.fetchForecast(city: _selectedCity);
  }

  void _changeCity(String city) {
    if (city == _selectedCity) {
      return;
    }
    setState(() {
      _selectedCity = city;
      _forecastFuture = _weatherService.fetchForecast(city: city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Advisory'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          _buildCitySelector(),
          const SizedBox(height: 12),
          FutureBuilder<WeatherReport>(
            future: _forecastFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError || snapshot.data == null) {
                return _buildErrorState();
              }

              return _buildWeatherContent(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCitySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _cities.map((city) {
        final isSelected = city == _selectedCity;
        return ChoiceChip(
          label: Text(city),
          selected: isSelected,
          selectedColor: kSecondaryColor.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? kPrimaryColor : kTextDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          onSelected: (_) => _changeCity(city),
        );
      }).toList(),
    );
  }

  Widget _buildWeatherContent(WeatherReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kAccentColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${report.locationName}, ${report.region} • ${report.currentTempC.toStringAsFixed(0)} C • ${report.currentConditionText}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: kTextDark),
          ),
        ),
        const SizedBox(height: 12),
        ...report.forecast.map(_buildForecastTile),
      ],
    );
  }

  Widget _buildForecastTile(WeatherForecastDay item) {
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
        leading: item.conditionIconUrl.isNotEmpty
            ? Image.network(item.conditionIconUrl, width: 36, height: 36)
            : const Icon(Icons.wb_sunny_outlined, color: kPrimaryColor),
        title: Text(
          '${item.date} • ${item.maxTempC.toStringAsFixed(0)} / ${item.minTempC.toStringAsFixed(0)} C',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(item.conditionText),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unable to load weather data.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text('Please check your connection and try again.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _forecastFuture =
                    _weatherService.fetchForecast(city: _selectedCity);
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
