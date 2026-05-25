import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/weather_model.dart';
import '../../services/location_service.dart';
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
  final LocationService _locService = LocationService();
  
  final List<String> _cities = const [
    'Use Current Location',
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
  String _selectedCity = 'Use Current Location';

  @override
  void initState() {
    super.initState();
    _loadInitialWeather();
  }

  void _loadInitialWeather() {
    _forecastFuture = _fetchWeatherForLocation();
  }

  Future<WeatherReport> _fetchWeatherForLocation() async {
    if (_selectedCity == 'Use Current Location') {
      final pos = await _locService.getCurrentLocation();
      if (pos != null) {
        return _weatherService.fetchForecastByCoords(
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      } else {
        // Fallback to default if location fails
        setState(() => _selectedCity = 'Lahore');
        return _weatherService.fetchForecast(city: 'Lahore');
      }
    } else {
      return _weatherService.fetchForecast(city: _selectedCity);
    }
  }

  void _changeCity(String? city) {
    if (city == null || city == _selectedCity) {
      return;
    }
    setState(() {
      _selectedCity = city;
      _forecastFuture = _fetchWeatherForLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          _buildCitySelector(),
          const SizedBox(height: 16),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          icon: const Icon(Icons.location_city, color: kPrimaryColor),
          items: _cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(
                city,
                style: TextStyle(
                  fontWeight: city == 'Use Current Location' ? FontWeight.w700 : FontWeight.normal,
                  color: city == 'Use Current Location' ? kPrimaryColor : kTextDark,
                ),
              ),
            );
          }).toList(),
          onChanged: _changeCity,
        ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryColor, kSecondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '${report.locationName}, ${report.region}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (report.currentConditionIconUrl.isNotEmpty)
                    Image.network(report.currentConditionIconUrl, width: 64, height: 64)
                  else
                    const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 48),
                  const SizedBox(width: 12),
                  Text(
                    '${report.currentTempC.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                report.currentConditionText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CurrentStat(icon: Icons.water_drop, label: 'Humidity', value: '${report.currentHumidity.toStringAsFixed(0)}%'),
                  _CurrentStat(icon: Icons.air, label: 'Wind', value: '${report.currentWindKph.toStringAsFixed(1)} kph'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '3-Day Forecast',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 12),
        ...report.forecast.map(_buildForecastTile),
      ],
    );
  }

  Widget _buildForecastTile(WeatherForecastDay item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          item.conditionIconUrl.isNotEmpty
              ? Image.network(item.conditionIconUrl, width: 42, height: 42)
              : const Icon(Icons.cloud, color: kPrimaryColor, size: 42),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.date,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kTextDark),
                ),
                Text(
                  item.conditionText,
                  style: const TextStyle(color: kTextLight, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.maxTempC.toStringAsFixed(0)}° / ${item.minTempC.toStringAsFixed(0)}°',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: kPrimaryColor),
              ),
              Row(
                children: [
                  const Icon(Icons.water_drop, size: 10, color: Colors.blue),
                  const SizedBox(width: 2),
                  Text('${item.avgHumidity.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: kTextLight)),
                  const SizedBox(width: 6),
                  const Icon(Icons.air, size: 10, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text('${item.maxWindKph.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: kTextLight)),
                ],
              ),
            ],
          ),
        ],
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
                _forecastFuture = _fetchWeatherForLocation();
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _CurrentStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CurrentStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}
