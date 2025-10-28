class Rental {
  final int carId;
  final DateTime startDate;
  final DateTime endDate;

  Rental({
    required this.carId,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
