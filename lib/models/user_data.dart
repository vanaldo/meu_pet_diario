// lib/models/user_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';

// Anotação Freezed para gerar a classe imutável e a lógica de JSON
// part 'user_data.freezed.dart';
// part 'user_data.g.dart';

class UserData {
  final String id;
  final String email;

  UserData({
    required this.id,
    required this.email,
  });

  // Métodos para serialização/desserialização de JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}