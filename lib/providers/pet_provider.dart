// lib/providers/pet_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meu_pet_diario/models/pet.dart';
import 'package:meu_pet_diario/models/pet_state.dart';

final petProvider = StateNotifierProvider<PetNotifier, PetState>((ref) {
  return PetNotifier();
});

class PetNotifier extends StateNotifier<PetState> {
  PetNotifier() : super(const PetState());

  final _storage = const FlutterSecureStorage();
  final String _baseUrl = "https://b6b118052f3c.ngrok-free.app";

  Future<void> fetchPets() async {
    state = state.copyWith(isLoading: true);
    try {
      final accessToken = await _storage.read(key: 'accessToken');
      if (accessToken == null) {
        state = state.copyWith(isLoading: false, pets: []);
        return;
      }
      final response = await http.get(
        Uri.parse('$_baseUrl/api/pets'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final pets = data.map((petData) => Pet.fromJson(petData)).toList();
        state = state.copyWith(isLoading: false, pets: pets);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Falha ao carregar pets');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro ao carregar pets: $e');
    }
  }

  Future<bool> createPet(Pet pet) async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');
      final url = '$_baseUrl/api/pets';

      print('Tentando criar pet na URL: $url');
      print('Dados do pet: ${pet.toJson()}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(pet.toJson()),
      );

      print('Resposta do servidor: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 201) {
        fetchPets();
        return true;
      } else {
        print('Falha ao adicionar pet: Status ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro de conexão ao tentar adicionar pet: $e');
      return false;
    }
  }
}