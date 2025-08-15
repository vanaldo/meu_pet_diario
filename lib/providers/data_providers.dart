import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meu_pet_diario/models/pet.dart';
import 'package:flutter/material.dart';
import 'package:meu_pet_diario/models/vacina.dart';
import 'package:meu_pet_diario/providers/vacinas_notifier.dart'; // Importação do novo provedor

final selectedPetIdProvider = StateProvider<String?>((ref) => null);
// A linha 'final vacinasProvider = StateProvider<List<Vacina>>((ref) => []);' não é mais necessária

final selectedPetVacinasProvider = Provider.autoDispose<List<Vacina>>((ref) {
  final allVacinas = ref.watch(vacinasProvider); // Agora observa o novo provedor
  final selectedPetId = ref.watch(selectedPetIdProvider);

  if (selectedPetId == null) {
    return [];
  }

  // Filtra as vacinas para mostrar apenas as do pet selecionado
  return allVacinas.where((vacina) => vacina.petId == selectedPetId).toList();
});

final petsProvider = StreamProvider.autoDispose<List<Pet>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  final stream = Supabase.instance.client
      .from('pets')
      .stream(primaryKey: ['id'])
      .eq('owner_id', userId)
      .order('name', ascending: true)
      .map((data) {
        final pets = data.map((json) => Pet.fromJson(json)).toList();
        
        // Se houver pets e nenhum estiver selecionado, selecione o primeiro
        if (pets.isNotEmpty && ref.read(selectedPetIdProvider) == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedPetIdProvider.notifier).state = pets.first.id;
          });
        }
        
        return pets;
      });
  return stream;
});