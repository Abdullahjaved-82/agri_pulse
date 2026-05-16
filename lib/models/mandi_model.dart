class MandiModel {
  final int id;
  final String name;
  final String city;
  final String province;
  final String distance;
  final bool isOpen;
  final int totalCrops;
  final double latitude;
  final double longitude;

  const MandiModel({
    required this.id,
    required this.name,
    required this.city,
    required this.province,
    required this.distance,
    required this.isOpen,
    required this.totalCrops,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory MandiModel.fromMap(Map<String, dynamic> map) {
    return MandiModel(
      id: map['id'] as int,
      name: map['name'] as String,
      city: map['city'] as String,
      province: map['province'] as String,
      distance: map['distance'] as String,
      isOpen: map['isOpen'] as bool,
      totalCrops: map['totalCrops'] as int,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

