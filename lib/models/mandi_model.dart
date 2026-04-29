class MandiModel {
  final int id;
  final String name;
  final String city;
  final String province;
  final String distance;
  final bool isOpen;
  final int totalCrops;

  const MandiModel({
    required this.id,
    required this.name,
    required this.city,
    required this.province,
    required this.distance,
    required this.isOpen,
    required this.totalCrops,
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
    );
  }
}

