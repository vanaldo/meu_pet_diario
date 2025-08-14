import 'package:flutter/material.dart';
import '../../models/pet_model.dart';
import '../../services/pet_service.dart';

class PetFormPage extends StatefulWidget {
  const PetFormPage({super.key});

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  DateTime? _birthDate;
  DateTime? _lastHeatDate;
  DateTime? _lastVaccineDate;
  DateTime? _lastFoodPurchaseDate;
  final _foodDurationCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _foodDurationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, ValueChanged<DateTime?> onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 30),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      onPicked(picked);
      setState(() {});
    }
  }

  Future<void> _savePet() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final pet = PetModel(
        name: _nameCtrl.text.trim(),
        birthDate: _birthDate,
        lastHeatDate: _lastHeatDate,
        lastVaccineDate: _lastVaccineDate,
        lastFoodPurchaseDate: _lastFoodPurchaseDate,
        foodDurationInDays: _foodDurationCtrl.text.isNotEmpty
            ? int.tryParse(_foodDurationCtrl.text)
            : null,
      );

      await PetService.I.addPet(pet);

      if (!mounted) return;
      Navigator.of(context).pop(true); // true = houve inserção
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar pet: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildDateField(String label, DateTime? date, ValueChanged<DateTime?> onPicked) {
    return InkWell(
      onTap: _loading ? null : () => _pickDate(context, onPicked),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date != null
              ? '${date.day.toString().padLeft(2, '0')}/'
                '${date.month.toString().padLeft(2, '0')}/'
                '${date.year}'
              : 'Selecionar data',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Pet')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Pet',
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe o nome';
                        return null;
                      },
                      enabled: !_loading,
                    ),
                    const SizedBox(height: 12),
                    _buildDateField('Data de Nascimento', _birthDate, (d) => _birthDate = d),
                    const SizedBox(height: 12),
                    _buildDateField('Último cio', _lastHeatDate, (d) => _lastHeatDate = d),
                    const SizedBox(height: 12),
                    _buildDateField('Última vacina', _lastVaccineDate, (d) => _lastVaccineDate = d),
                    const SizedBox(height: 12),
                    _buildDateField(
                        'Última compra de ração', _lastFoodPurchaseDate, (d) => _lastFoodPurchaseDate = d),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _foodDurationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Duração da ração (dias)',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !_loading,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _loading ? null : _savePet,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
