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
    return CropModel(
      id: map['id'] as int,
      name: map['name'] as String,
      urduName: map['urduName'] as String,
      price: (map['price'] as num).toDouble(),
      previousPrice: (map['previousPrice'] as num).toDouble(),
      trend: map['trend'] as String,
      category: map['category'] as String,
      imageEmoji: map['imageEmoji'] as String,
      unit: map['unit'] as String,
    );
  }
}

