class Car {
  final int id;
  final String model;
  final String brand;
  final bool isActive;  // <- coincide con tu API
  final double pricePerDay;

  Car({
    required this.id,
    required this.model,
    required this.brand,
    required this.isActive,
    required this.pricePerDay,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      model: json['model'],
      brand: json['brand'],
      isActive: json['is_active'],  // <- corresponde al API
      pricePerDay: double.parse(json['price_per_day'].toString()), // parse seguro
    );
  }
}
