import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GroqService {
  GroqService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> generateRecommendation({
    required String prompt,
    String model = 'llama-3.1-8b-instant',
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY is missing');
    }

    final uri = Uri.https('api.groq.com', '/openai/v1/chat/completions');
    final body = jsonEncode({
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are AgriPulse assistant. Provide short, practical agricultural guidance for Pakistan.',
        },
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.6,
    });

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>? ?? const [];
    if (choices.isEmpty) {
      return 'No recommendation available.';
    }

    final message = choices.first as Map<String, dynamic>;
    final content = (message['message'] as Map<String, dynamic>?)?['content'];
    return content?.toString().trim().isNotEmpty == true
        ? content.toString().trim()
        : 'No recommendation available.';
  }

  /// Generate a structured crop advisory with BUY/SELL/HOLD recommendation.
  /// Returns a map with keys: recommendation, reasoning, confidence.
  Future<Map<String, String>> generateCropAdvisory({
    required String cropName,
    required double currentPrice,
    required double previousPrice,
    required String trend,
    required List<double> priceHistory7d,
    required String region,
  }) async {
    final month = DateTime.now().month;
    final seasonName = _getSeason(month);
    final trendPct = previousPrice == 0
        ? '0'
        : ((currentPrice - previousPrice) / previousPrice * 100)
            .toStringAsFixed(1);

    final historyStr = priceHistory7d.map((p) => p.toStringAsFixed(0)).join(', ');

    final prompt = '''
Analyze the following commodity data and respond ONLY with valid JSON — no markdown, no explanation:

Commodity: $cropName
Current Price: PKR ${currentPrice.toStringAsFixed(0)} per 40kg
Previous Price: PKR ${previousPrice.toStringAsFixed(0)} per 40kg
7-Day Trend: $trend ($trendPct%)
7-Day Price History (oldest to newest): $historyStr
Season: $seasonName (Month: $month)
Region: $region, Pakistan

Respond with EXACTLY this JSON format:
{"recommendation": "BUY" or "SELL" or "HOLD", "reasoning": "2-3 sentences explaining why", "confidence": "High" or "Medium" or "Low"}
''';

    final response = await generateRecommendation(prompt: prompt);

    // Try to parse JSON from the response
    try {
      // Find the JSON object in the response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonStr = response.substring(jsonStart, jsonEnd + 1);
        final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
        return {
          'recommendation': (parsed['recommendation'] ?? 'HOLD').toString().toUpperCase(),
          'reasoning': (parsed['reasoning'] ?? 'Unable to analyze at this time.').toString(),
          'confidence': (parsed['confidence'] ?? 'Medium').toString(),
        };
      }
    } catch (_) {
      // Fall through to defaults
    }

    // Fallback: simple heuristic if AI parsing fails
    String rec = 'HOLD';
    String reasoning = 'Market conditions are stable. Monitor price movements before making decisions.';
    if (trend == 'up' && currentPrice > previousPrice) {
      rec = 'SELL';
      reasoning = 'Prices are trending upward. Consider selling to lock in profits while the market is favorable.';
    } else if (trend == 'down' && currentPrice < previousPrice) {
      rec = 'BUY';
      reasoning = 'Prices are declining. This could be a good buying opportunity if you expect a rebound.';
    }

    return {
      'recommendation': rec,
      'reasoning': reasoning,
      'confidence': 'Medium',
    };
  }

  String _getSeason(int month) {
    if (month >= 3 && month <= 5) return 'Rabi Harvest / Spring';
    if (month >= 6 && month <= 8) return 'Kharif Sowing / Summer';
    if (month >= 9 && month <= 11) return 'Kharif Harvest / Autumn';
    return 'Rabi Sowing / Winter';
  }
}
