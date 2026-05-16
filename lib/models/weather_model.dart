class WeatherForecastDay {
  final String date;
  final double maxTempC;
  final double minTempC;
  final String conditionText;
  final String conditionIconUrl;

  WeatherForecastDay({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.conditionText,
    required this.conditionIconUrl,
  });

  factory WeatherForecastDay.fromMap(Map<String, dynamic> map) {
    final day = map['day'] as Map<String, dynamic>;
    final condition = day['condition'] as Map<String, dynamic>;
    return WeatherForecastDay(
      date: map['date']?.toString() ?? '',
      maxTempC: (day['maxtemp_c'] as num?)?.toDouble() ?? 0,
      minTempC: (day['mintemp_c'] as num?)?.toDouble() ?? 0,
      conditionText: condition['text']?.toString() ?? 'Unknown',
      conditionIconUrl: _normalizeIconUrl(condition['icon']?.toString() ?? ''),
    );
  }
}

class WeatherReport {
  final String locationName;
  final String region;
  final String country;
  final double currentTempC;
  final String currentConditionText;
  final String currentConditionIconUrl;
  final List<WeatherForecastDay> forecast;

  WeatherReport({
    required this.locationName,
    required this.region,
    required this.country,
    required this.currentTempC,
    required this.currentConditionText,
    required this.currentConditionIconUrl,
    required this.forecast,
  });

  factory WeatherReport.fromMap(Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>;
    final current = map['current'] as Map<String, dynamic>;
    final currentCondition = current['condition'] as Map<String, dynamic>;
    final forecastDays = (map['forecast'] as Map<String, dynamic>)['forecastday']
            as List<dynamic>? ??
        const [];

    return WeatherReport(
      locationName: location['name']?.toString() ?? '',
      region: location['region']?.toString() ?? '',
      country: location['country']?.toString() ?? '',
      currentTempC: (current['temp_c'] as num?)?.toDouble() ?? 0,
      currentConditionText: currentCondition['text']?.toString() ?? 'Unknown',
      currentConditionIconUrl:
          _normalizeIconUrl(currentCondition['icon']?.toString() ?? ''),
      forecast: forecastDays
          .map((item) => WeatherForecastDay.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

String _normalizeIconUrl(String iconPath) {
  if (iconPath.startsWith('http')) {
    return iconPath;
  }
  if (iconPath.startsWith('//')) {
    return 'https:$iconPath';
  }
  if (iconPath.isEmpty) {
    return '';
  }
  return 'https://$iconPath';
}

