import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/weather_model.dart';
import '../services/groq_service.dart';
import '../services/weather_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/language_provider.dart';

class AiAdvisoryCard extends StatefulWidget {
  const AiAdvisoryCard({super.key, this.title = 'AI Advisory'});

  final String title;

  @override
  State<AiAdvisoryCard> createState() => _AiAdvisoryCardState();
}

class _AiAdvisoryCardState extends State<AiAdvisoryCard> {
  static const Duration _cacheTtl = Duration(minutes: 30);
  static final Map<String, _AdvisoryCache> _cache = {};

  final GroqService _groqService = GroqService();
  final WeatherService _weatherService = WeatherService();

  late List<String> _cropOptions;
  String _insightCrop = 'Wheat';
  String _insightCity = 'Lahore';
  DateTime? _lastUpdated;
  bool _usedCache = false;
  bool _initialized = false;

  Future<String>? _advisoryFuture;
  Future<WeatherReport>? _weatherFuture;

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

  @override
  void initState() {
    super.initState();
    _cropOptions = DummyData.crops
        .map((crop) => crop['name'] as String)
        .toSet()
        .toList();
    _cropOptions.sort();
    if (_cropOptions.isNotEmpty) {
      _insightCrop = _cropOptions.first;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _refreshAdvisory();
    }
  }

  Future<void> _refreshAdvisory({bool force = false}) async {
    final bool isUrdu = LanguageScope.of(context).isUrdu;
    final String crop = _insightCrop;
    final String city = _insightCity;
    final String cacheKey = _buildCacheKey(crop, city, isUrdu);
    final _AdvisoryCache? cached = _cache[cacheKey];
    final DateTime now = DateTime.now();

    final weatherFuture = _weatherService.fetchForecast(city: city);

    if (!force && cached != null && now.difference(cached.timestamp) < _cacheTtl) {
      setState(() {
        _weatherFuture = weatherFuture;
        _advisoryFuture = Future.value(cached.text);
        _lastUpdated = cached.timestamp;
        _usedCache = true;
      });
      return;
    }

    setState(() {
      _weatherFuture = weatherFuture;
      _advisoryFuture = _buildAdvisory(
        crop: crop,
        city: city,
        weatherFuture: weatherFuture,
        isUrdu: isUrdu,
      );
      _lastUpdated = now;
      _usedCache = false;
    });
  }

  Future<String> _buildAdvisory({
    required String crop,
    required String city,
    required Future<WeatherReport> weatherFuture,
    required bool isUrdu,
  }) async {
    WeatherReport? report;
    try {
      report = await weatherFuture;
    } catch (_) {
      report = null;
    }

    final String weatherLine = report == null
        ? (isUrdu ? 'موسمی ڈیٹا دستیاب نہیں ہے۔' : 'Weather data is unavailable.')
        : isUrdu
            ? '$city میں موجودہ موسم: ${report.currentConditionText}, '
                '${report.currentTempC.toStringAsFixed(0)} ڈگری سینٹی گریڈ۔'
            : 'Current weather in $city: ${report.currentConditionText}, '
                '${report.currentTempC.toStringAsFixed(0)} C.';

    final String prompt = isUrdu
        ? 'براہِ کرم $city، پاکستان میں $crop کے کسانوں کے لیے 3-4 لائنوں میں مشورہ دیں۔ '
            '$weatherLine مختصر مارکیٹ رجحان اور ایک عملی ٹِپ ضرور دیں۔ '
            'صرف اردو رسم الخط میں جواب دیں، رومن اردو استعمال نہ کریں۔ '
            'جواب صرف سادہ متن (plain text) میں دیں۔ مارک ڈاؤن، ستارے (*)، یا بلٹ پوائنٹس استعمال نہ کریں۔ انتہائی پیشہ ورانہ انداز اپنائیں۔'
        : 'Give a highly professional 3-4 line recommendation for $crop farmers in $city, Pakistan today. '
            '$weatherLine Include a brief market trend note and a practical tip. '
            'CRITICAL: Respond ONLY in plain text paragraphs. DO NOT use markdown, bold text, stars (*), or bullet points.';

    final String response =
        await _groqService.generateRecommendation(prompt: prompt);

    _cache[_buildCacheKey(crop, city, isUrdu)] = _AdvisoryCache(
      text: response,
      timestamp: DateTime.now(),
    );

    return response;
  }

  String _buildCacheKey(String crop, String city, bool isUrdu) {
    return '$crop|$city|${isUrdu ? 'ur' : 'en'}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUrdu = LanguageScope.of(context).isUrdu;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: kSecondaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(kDefaultBorderRadius),
                topRight: Radius.circular(kDefaultBorderRadius),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🌿',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _refreshAdvisory(force: true),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh advisory',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectors(context),
                const SizedBox(height: 12),
                if (_weatherFuture != null)
                  FutureBuilder<WeatherReport>(
                    future: _weatherFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: LinearProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            isUrdu
                                ? 'موسم کی جھلک دستیاب نہیں ہے۔'
                                : 'Weather preview unavailable.',
                            style: const TextStyle(color: kTextLight),
                          ),
                        );
                      }
                      final report = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          isUrdu
                              ? '${report.locationName} • '
                                  '${report.currentTempC.toStringAsFixed(0)} ڈگری سینٹی گریڈ • '
                                  '${report.currentConditionText}'
                              : '${report.locationName} • '
                                  '${report.currentTempC.toStringAsFixed(0)} C • '
                                  '${report.currentConditionText}',
                          style: const TextStyle(
                            color: kTextDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                if (_advisoryFuture == null)
                  Text(
                    isUrdu
                        ? 'آج کے مشورے کے لیے ریفریش دبائیں۔'
                        : 'Tap refresh to get today\'s advisory.',
                  )
                else
                  FutureBuilder<String>(
                    future: _advisoryFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: LinearProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(
                          isUrdu
                              ? 'مشورہ اس وقت لوڈ نہیں ہو رہا۔ براہِ کرم دوبارہ کوشش کریں۔'
                              : 'Unable to load advisory right now. Please try again.',
                          style: const TextStyle(color: kTextLight),
                        );
                      }

                      return Text(
                        snapshot.data ?? 'No advisory available.',
                        style: const TextStyle(
                          color: kTextDark,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                if (_lastUpdated != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      isUrdu
                          ? 'تازہ کاری: ${_lastUpdated!.toLocal().toString().substring(0, 16)}'
                              '${_usedCache ? ' • کیشڈ' : ''}'
                          : 'Updated: ${_lastUpdated!.toLocal().toString().substring(0, 16)}'
                              '${_usedCache ? ' • Cached' : ''}',
                      style: const TextStyle(color: kTextLight, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectors(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 360;
        if (isNarrow) {
          return Column(
            children: [
              _buildCropDropdown(),
              const SizedBox(height: 10),
              _buildCityDropdown(),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildCropDropdown()),
            const SizedBox(width: 10),
            Expanded(child: _buildCityDropdown()),
          ],
        );
      },
    );
  }

  Widget _buildCropDropdown() {
    return DropdownButtonFormField<String>(
      key: ValueKey(_insightCrop),
      initialValue: _insightCrop,
      items: _cropOptions
          .map(
            (crop) => DropdownMenuItem<String>(
              value: crop,
              child: Text(crop),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _insightCrop = value;
        });
        _refreshAdvisory();
      },
      decoration: const InputDecoration(
        labelText: 'Crop Focus',
        prefixIcon: Icon(Icons.auto_graph),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      key: ValueKey(_insightCity),
      initialValue: _insightCity,
      items: _cities
          .map(
            (city) => DropdownMenuItem<String>(
              value: city,
              child: Text(city),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _insightCity = value;
        });
        _refreshAdvisory();
      },
      decoration: const InputDecoration(
        labelText: 'City',
        prefixIcon: Icon(Icons.location_on_outlined),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _AdvisoryCache {
  final String text;
  final DateTime timestamp;

  _AdvisoryCache({required this.text, required this.timestamp});
}
