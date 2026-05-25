import 'dart:convert';

class PriceAlertModel {
  final String id;
  final String commodityName;
  final double targetPrice;
  final String condition; // 'above' or 'below'
  final String mandiId;
  final bool enabled;
  final DateTime createdAt;

  const PriceAlertModel({
    required this.id,
    required this.commodityName,
    required this.targetPrice,
    required this.condition,
    required this.mandiId,
    required this.enabled,
    required this.createdAt,
  });

  PriceAlertModel copyWith({
    String? id,
    String? commodityName,
    double? targetPrice,
    String? condition,
    String? mandiId,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return PriceAlertModel(
      id: id ?? this.id,
      commodityName: commodityName ?? this.commodityName,
      targetPrice: targetPrice ?? this.targetPrice,
      condition: condition ?? this.condition,
      mandiId: mandiId ?? this.mandiId,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'commodityName': commodityName,
        'targetPrice': targetPrice,
        'condition': condition,
        'mandiId': mandiId,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PriceAlertModel.fromJson(Map<String, dynamic> json) {
    return PriceAlertModel(
      id: json['id'] as String,
      commodityName: json['commodityName'] as String,
      targetPrice: (json['targetPrice'] as num).toDouble(),
      condition: json['condition'] as String,
      mandiId: json['mandiId'] as String,
      enabled: json['enabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static List<PriceAlertModel> listFromJson(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((item) =>
            PriceAlertModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<PriceAlertModel> alerts) {
    return jsonEncode(alerts.map((a) => a.toJson()).toList());
  }
}
