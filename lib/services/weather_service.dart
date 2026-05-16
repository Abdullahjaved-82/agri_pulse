import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherReport> fetchForecast({
    required String city,
    int days = 7,
  }) async {
    final apiKey = dotenv.env['WEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('WEATHER_API_KEY is missing');
    }

    final uri = Uri.https('api.weatherapi.com', '/v1/forecast.json', {
      'key': apiKey,
      'q': city,
      'days': days.toString(),
      'aqi': 'no',
      'alerts': 'no',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Weather API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherReport.fromMap(data);
  }
}

