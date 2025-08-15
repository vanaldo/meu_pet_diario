// lib/models/pet_state.dart
import 'package:meu_pet_diario/models/pet.dart';

class PetState {
  final List<Pet> pets;
  final bool isLoading;
  final String? errorMessage;

  const PetState({
    this.pets = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PetState copyWith({
    List<Pet>? pets,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PetState(
      pets: pets ?? this.pets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}