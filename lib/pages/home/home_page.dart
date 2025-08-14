import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/pet_service.dart';
import '../../models/pet_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  List<PetModel> _pets = [];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() => _loading = true);
    try {
      final pets = await PetService.I.getPets();
      if (mounted) setState(() => _pets = pets);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pets: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.I.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPets,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _pets.isEmpty
                ? const Center(child: Text('Nenhum pet encontrado.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final pet = _pets[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.pets, size: 32),
                          title: Text(pet.name),
                          subtitle: Text(
                            _formatDates(pet),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            // aqui poderia abrir uma tela de detalhes/edição
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/pet_form');
          if (result == true) _loadPets();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDates(PetModel pet) {
    final parts = <String>[];
    if (pet.birthDate != null) {
      parts.add('Nascimento: ${_formatDate(pet.birthDate)}');
    }
    if (pet.lastVaccineDate != null) {
      parts.add('Última vacina: ${_formatDate(pet.lastVaccineDate)}');
    }
    if (pet.lastFoodPurchaseDate != null) {
      parts.add('Compra ração: ${_formatDate(pet.lastFoodPurchaseDate)}');
    }
    return parts.isEmpty ? 'Sem informações adicionais' : parts.join(' | ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
