import '../data/dummy_data.dart';

class CropModel {
  final int id;
  final String name;
  final String urduName;
  final double price;
  final double previousPrice;
  final String trend;
  final String category;
  final String imageEmoji;
  final String unit;

  const CropModel({
    required this.id,
    required this.name,
    required this.urduName,
    required this.price,
    required this.previousPrice,
    required this.trend,
    required this.category,
    required this.imageEmoji,
    required this.unit,
  });

  factory CropModel.fromMap(Map<String, dynamic> map) {
    final String name = map['name'] as String? ?? '';
    
    // Find matching dummy crop to recover rich metadata (emoji, urduName, category, etc.)
    final dummyCrop = dummyCrops.firstWhere(
      (c) {
        final cName = (c['name'] as String).toLowerCase();
        final sName = name.toLowerCase();
        return cName.contains(sName) || sName.contains(cName);
      },
      orElse: () => <String, dynamic>{},
    );

    return CropModel(
      id: map['id'] as int? ?? dummyCrop['id'] as int? ?? 0,
      name: name.isNotEmpty ? name : (dummyCrop['name'] as String? ?? ''),
      urduName: map['urduName'] as String? ?? dummyCrop['urduName'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? (dummyCrop['price'] as num?)?.toDouble() ?? 0.0,
      previousPrice: (map['previousPrice'] as num?)?.toDouble() ?? (dummyCrop['previousPrice'] as num?)?.toDouble() ?? 0.0,
      trend: map['trend'] as String? ?? dummyCrop['trend'] as String? ?? 'stable',
      category: map['category'] as String? ?? dummyCrop['category'] as String? ?? '',
      imageEmoji: map['imageEmoji'] as String? ?? dummyCrop['imageEmoji'] as String? ?? '🌱',
      unit: map['unit'] as String? ?? dummyCrop['unit'] as String? ?? 'PKR',
    );
  }
}

