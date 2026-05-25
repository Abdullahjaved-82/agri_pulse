import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// A structured news article returned by the Groq news service.
class GroqNewsArticle {
  final String title;
  final String description;
  final String category;
  final String emoji;
  final String date;
  final bool isLive; // true = fetched live from Groq

  const GroqNewsArticle({
    required this.title,
    required this.description,
    required this.category,
    required this.emoji,
    required this.date,
    this.isLive = false,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'emoji': emoji,
        'date': date,
        'isLive': isLive,
      };

  factory GroqNewsArticle.fromMap(Map<String, dynamic> m) => GroqNewsArticle(
        title: m['title'] as String? ?? '',
        description: m['description'] as String? ?? '',
        category: m['category'] as String? ?? 'News',
        emoji: m['emoji'] as String? ?? '📰',
        date: m['date'] as String? ?? '',
        isLive: m['isLive'] as bool? ?? false,
      );
}

class GroqNewsService {
  GroqNewsService({http.Client? client, FirebaseFirestore? firestore})
      : _client = client ?? http.Client(),
        _providedFirestore = firestore;

  final http.Client _client;
  final FirebaseFirestore? _providedFirestore;

  FirebaseFirestore get _firestore => _providedFirestore ?? FirebaseFirestore.instance;

  static const _cacheHours = 6; // refresh cache every 6 hours
  static const _model = 'llama-3.1-8b-instant';

  /// Returns the cache document key for today (YYYY-MM-DD-HH/6 block).
  String get _cacheKey {
    final now = DateTime.now();
    final block = now.hour ~/ _cacheHours;
    return '${DateFormat('yyyy-MM-dd').format(now)}-$block';
  }

  /// Fetches latest Pakistan agriculture news.
  /// - Checks Firestore cache first (valid for 6 hours).
  /// - Falls back to Groq API if cache is stale or empty.
  /// - Persists new results to Firestore cache.
  Future<List<GroqNewsArticle>> fetchNews({bool forceRefresh = false}) async {
    // 1. Try cache
    if (!forceRefresh) {
      final cached = await _loadFromCache();
      if (cached != null && cached.isNotEmpty) return cached;
    }

    // 2. Call Groq API
    try {
      final articles = await _fetchFromGroq();
      if (articles.isNotEmpty) {
        await _saveToCache(articles);
        return articles;
      }
    } catch (e) {
      // If Groq fails, try serving stale cache
      final stale = await _loadFromCache(ignoreExpiry: true);
      if (stale != null && stale.isNotEmpty) return stale;
    }

    return fallbackNews();
  }

  // ── Groq API ───────────────────────────────────────────────────────────────
  Future<List<GroqNewsArticle>> _fetchFromGroq() async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) throw Exception('GROQ_API_KEY missing');

    final today = DateFormat('dd MMMM yyyy').format(DateTime.now());

    final prompt = '''
You are an agriculture news assistant for Pakistan (Punjab region). Today is $today.

Generate exactly 6 recent Pakistan agriculture news items. Return ONLY valid JSON array, no extra text.

Format:
[
  {
    "title": "News headline (max 80 chars)",
    "description": "2-3 sentence summary of the news",
    "category": "Market|Weather|Government|Tips|Export|Punjab",
    "emoji": "single relevant emoji"
  }
]

Topics to cover: wheat/rice/cotton prices in Punjab mandis, government agricultural policies, weather impact on crops, farming tips, export news, fertilizer/pesticide updates. Make them realistic and current for Pakistan.
''';

    final response = await _client.post(
      Uri.https('api.groq.com', '/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a Pakistan agricultural news assistant. Always respond with valid JSON only, no markdown, no explanation.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 1200,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>? ?? [];
    if (choices.isEmpty) throw Exception('No choices in Groq response');

    final content = ((choices.first as Map)['message'] as Map)['content'] as String? ?? '';

    // Parse JSON from the content (strip any stray markdown fences)
    final cleaned = content
        .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```\s*', multiLine: true), '')
        .trim();

    final List<dynamic> rawList = jsonDecode(cleaned) as List<dynamic>;
    final today2 = DateFormat('dd MMM yyyy').format(DateTime.now());

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((m) => GroqNewsArticle(
              title: m['title'] as String? ?? '',
              description: m['description'] as String? ?? '',
              category: m['category'] as String? ?? 'News',
              emoji: m['emoji'] as String? ?? '📰',
              date: today2,
              isLive: true,
            ))
        .where((a) => a.title.isNotEmpty)
        .toList();
  }

  // ── Firestore Cache ────────────────────────────────────────────────────────
  Future<List<GroqNewsArticle>?> _loadFromCache({bool ignoreExpiry = false}) async {
    try {
      final doc =
          await _firestore.collection('news_cache').doc(_cacheKey).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      if (!ignoreExpiry) {
        final fetchedAt = (data['fetchedAt'] as Timestamp?)?.toDate();
        if (fetchedAt == null) return null;
        if (DateTime.now().difference(fetchedAt).inHours >= _cacheHours) return null;
      }

      final items = (data['articles'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GroqNewsArticle.fromMap)
          .toList();
      return items.isEmpty ? null : items;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(List<GroqNewsArticle> articles) async {
    try {
      await _firestore.collection('news_cache').doc(_cacheKey).set({
        'fetchedAt': FieldValue.serverTimestamp(),
        'articles': articles.map((a) => a.toMap()).toList(),
      });
    } catch (_) {
      // Cache write failure is non-fatal
    }
  }

  // ── Hard-coded fallback (public for home screen) ───────────────────────────
  List<GroqNewsArticle> fallbackNews() {
    final today = DateFormat('dd MMM yyyy').format(DateTime.now());
    return [
      GroqNewsArticle(
        title: 'Punjab Wheat Procurement Drive Underway',
        description:
            'Government procurement centers across Punjab are actively buying wheat at the support price. Farmers are advised to bring produce with proper moisture content.',
        category: 'Government',
        emoji: '🌾',
        date: today,
      ),
      GroqNewsArticle(
        title: 'Cotton Prices Rise on Strong Textile Demand',
        description:
            'Cotton rates in Multan and Bahawalpur mandis have risen 4% this week as textile mills increase procurement ahead of export season.',
        category: 'Market',
        emoji: '🏭',
        date: today,
      ),
      GroqNewsArticle(
        title: 'Advisory: Protect Crops from Late Season Rain',
        description:
            'Agricultural extension teams warn of fungal disease risk after recent rains. Farmers should apply preventive fungicide and ensure proper drainage.',
        category: 'Weather',
        emoji: '🌧️',
        date: today,
      ),
      GroqNewsArticle(
        title: 'Mango Season Begins in South Punjab',
        description:
            'Early mango varieties from Multan and Rahim Yar Khan have started arriving in markets. Growers expect good yield due to favorable spring weather.',
        category: 'Punjab',
        emoji: '🥭',
        date: today,
      ),
      GroqNewsArticle(
        title: 'Urea Fertilizer Supply Stabilized Across Punjab',
        description:
            'NFML confirms sufficient urea stock at all district depots. Farmers can purchase at fixed government rates from registered dealers.',
        category: 'Government',
        emoji: '🌱',
        date: today,
      ),
      GroqNewsArticle(
        title: 'Rice Export Target Set at \$3 Billion',
        description:
            'Pakistan aims to export \$3 billion worth of rice this fiscal year. Basmati growers in Punjab are being encouraged to adopt certified seed varieties.',
        category: 'Export',
        emoji: '🍚',
        date: today,
      ),
    ];
  }
}
