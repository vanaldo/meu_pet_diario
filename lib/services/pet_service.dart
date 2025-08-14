import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';
import 'supabase_service.dart';

class PetService {
  PetService._();
  static final PetService I = PetService._();

  SupabaseClient get _cli => SupabaseService.client;

  /// Lista todos os pets do usuário logado.
  /// Graças às policies (RLS), só retorna os pets do owner atual.
  Future<List<PetModel>> getPets() async {
    await SupabaseService.init();
    try {
      final res = await _cli.from('pets').select().order('name', ascending: true);

      if (res is List) {
        return res.map((e) => PetModel.fromMap(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar pets: $e');
    }
  }

  /// Adiciona um novo pet.
  /// Envia explicitamente o owner_id = auth.uid() para satisfazer a policy de INSERT.
  Future<void> addPet(PetModel pet) async {
    await SupabaseService.init();
    try {
      final insertData = pet.toMap();
      // remove chaves com null para evitar problemas no insert
      insertData.removeWhere((key, value) => value == null);

      final uid = SupabaseService.user?.id;
      if (uid == null) {
        throw Exception('Usuário não autenticado.');
      }
      insertData['owner_id'] = uid; // << chave para passar no RLS

      final res = await _cli.from('pets').insert(insertData);
      dev.log('addPet -> $res', name: 'PetService');
    } catch (e) {
      throw Exception('Erro ao adicionar pet: $e');
    }
  }

  /// Atualiza um pet existente (apenas do dono).
  Future<void> updatePet(PetModel pet) async {
    if (pet.id == null) throw Exception('Pet sem ID não pode ser atualizado.');
    await SupabaseService.init();
    try {
      final updateData = pet.toMap();
      updateData.removeWhere((key, value) => value == null);

      final res = await _cli.from('pets').update(updateData).eq('id', pet.id!);
      dev.log('updatePet -> $res', name: 'PetService');
    } catch (e) {
      throw Exception('Erro ao atualizar pet: $e');
    }
  }

  /// Remove um pet pelo id (apenas do dono).
  Future<void> deletePet(String id) async {
    await SupabaseService.init();
    try {
      final res = await _cli.from('pets').delete().eq('id', id);
      dev.log('deletePet -> $res', name: 'PetService');
    } catch (e) {
      throw Exception('Erro ao remover pet: $e');
    }
  }
}
