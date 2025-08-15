import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:meu_pet_diario/models/vacina.dart';

class VacinasNotifier extends StateNotifier<List<Vacina>> {
  VacinasNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    final box = await Hive.openBox<Vacina>('vacinas');
    state = box.values.toList();
  }

  Future<void> addVacina(Vacina vacina) async {
    final box = await Hive.openBox<Vacina>('vacinas');
    await box.add(vacina);
    state = [...state, vacina];
  }
}

final vacinasProvider = StateNotifierProvider<VacinasNotifier, List<Vacina>>((ref) {
  return VacinasNotifier();
});