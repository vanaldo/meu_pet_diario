class PetModel {
  final String? id; // UUID
  final String name;
  final DateTime? birthDate;
  final DateTime? lastHeatDate;
  final DateTime? lastVaccineDate;
  final DateTime? lastFoodPurchaseDate;
  final int? foodDurationInDays;

  PetModel({
    this.id,
    required this.name,
    this.birthDate,
    this.lastHeatDate,
    this.lastVaccineDate,
    this.lastFoodPurchaseDate,
    this.foodDurationInDays,
  });

  factory PetModel.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return PetModel(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      birthDate: _parseDate(map['birth_date']),
      lastHeatDate: _parseDate(map['last_heat_date'] ?? map['last_heat_dat']),
      lastVaccineDate: _parseDate(map['last_vaccine_date']),
      lastFoodPurchaseDate: _parseDate(map['last_food_purchase_date']),
      foodDurationInDays: map['food_duration_in_days'] != null
          ? int.tryParse(map['food_duration_in_days'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    String? _formatDate(DateTime? date) =>
        date != null ? date.toIso8601String().split('T').first : null;

    return {
      if (id != null) 'id': id,
      'name': name,
      'birth_date': _formatDate(birthDate),
      'last_heat_date': _formatDate(lastHeatDate),
      'last_vaccine_date': _formatDate(lastVaccineDate),
      'last_food_purchase_date': _formatDate(lastFoodPurchaseDate),
      'food_duration_in_days': foodDurationInDays,
    };
  }
}
