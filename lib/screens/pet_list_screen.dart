// lib/screens/pet_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_pet_diario/providers/pet_provider.dart';
import 'package:meu_pet_diario/models/pet_state.dart';

class PetListScreen extends ConsumerWidget {
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navegar para a tela de adicionar pet
            },
          ),
        ],
      ),
      body: _buildBody(petState),
    );
  }

  Widget _buildBody(PetState petState) {
    if (petState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (petState.errorMessage != null) {
      return Center(child: Text(petState.errorMessage!));
    } else if (petState.pets.isEmpty) {
      return const Center(child: Text('Nenhum pet encontrado.'));
    } else {
      return ListView.builder(
        itemCount: petState.pets.length,
        itemBuilder: (context, index) {
          final pet = petState.pets[index];
          return ListTile(
            title: Text(pet.name),
            subtitle: Text('Data de nascimento: ${pet.birthDate.toString()}'),
            // Adicione mais informações e ações aqui
          );
        },
      );
    }
  }
}