// lib/models/pet.dart
import 'dart:convert';

class Pet {
  final String? id;
  final String name;
  final DateTime birthDate;
  final String ownerId;

  Pet({
    this.id,
    required this.name,
    required this.birthDate,
    required this.ownerId,
  });

  // Construtor para criar um Pet a partir de JSON
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      ownerId: json['owner_id'] as String,
    );
  }

  // Método para converter um Pet para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birth_date': birthDate.toIso8601String(),
      'owner_id': ownerId,
    };
  }
}