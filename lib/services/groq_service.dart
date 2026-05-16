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
}

