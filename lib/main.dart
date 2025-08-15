// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meu_pet_diario/providers/auth_provider.dart';
import 'package:meu_pet_diario/screens/login_screen.dart';
import 'package:meu_pet_diario/screens/pet_list_screen.dart';
import 'package:meu_pet_diario/models/pet_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones(); // Inicialização do timezone

  // CORREÇÃO: Usando o ícone padrão do launcher para notificações
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await Supabase.initialize(
    url: 'https://qgfhmodijstlilfebcvl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFnZmhtb2RpanN0bGlsZmViY3ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2NjIzNTYsImV4cCI6MjA3MDIzODM1Nn0.lSkiMC9i6-DJBj2Jho8aKxkyJzWSeobTOEr26Q-m-1Y',
  );

  runApp(
    const ProviderScope(
      child: PetApp(),
    ),
  );
}

class PetApp extends StatelessWidget {
  const PetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu Pet Diário',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF7C4DFF),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF7C4DFF),
        brightness: Brightness.dark,
      ),
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends ConsumerWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return const PetShell();
    } else {
      return const LoginScreen();
    }
  }
}

class PetShell extends StatefulWidget {
  const PetShell({super.key});

  @override
  State<PetShell> createState() => _PetShellState();
}

class _PetShellState extends State<PetShell> {
  int _index = 0;

  late final List<Widget> _pages = [
    const DashboardPage(),
    const DiarioPage(),
    const AgendaPage(),
    const VacinasPage(),
    const PerfilUsuarioPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final pageTitles = ['Resumo', 'Diário', 'Agenda', 'Vacinas', 'Perfil'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Pet — ${pageTitles[_index]}'),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Resumo'),
          NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Diário'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.vaccines_outlined), selectedIcon: Icon(Icons.vaccines), label: 'Vacinas'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ===== MODELOS SIMPLES (in-memory) =====
class Pet {
  final String id;
  final String nome;
  final String raca;
  final int idade;
  final double peso;
  final IconData icone;
  final String sexo;
  final String microchip;
  final bool castrado;

  Pet({required this.id, required this.nome, required this.raca, required this.idade, required this.peso, this.icone = Icons.pets, required this.sexo, required this.microchip, required this.castrado});
}

class DiarioEntry {
  final DateTime data;
  final String titulo;
  final String nota;
  final IconData icone;
  final String petId;
  DiarioEntry({required this.data, required this.titulo, required this.nota, required this.petId, this.icone = Icons.check_circle});
}

class EventoAgenda {
  final DateTime quando;
  final String titulo;
  final String local;
  final IconData icone;
  final String petId;
  EventoAgenda({required this.quando, required this.titulo, required this.local, required this.petId, this.icone = Icons.event});
}

class VacinaItem {
  final String nome;
  final DateTime? aplicadaEm;
  final DateTime? proxima;
  final String petId;
  VacinaItem({required this.nome, this.aplicadaEm, this.proxima, required this.petId});
}

// ===== DADOS MOCK =====
final List<Pet> _pets = [
  Pet(id: 'thor', nome: 'Thor', raca: 'SRD', idade: 3, peso: 12.5, sexo: 'Macho', microchip: '000123456789', castrado: true),
  Pet(id: 'luna', nome: 'Luna', raca: 'Siamês', idade: 2, peso: 4.2, sexo: 'Fêmea', microchip: '000987654321', castrado: true),
];

final List<DiarioEntry> _diario = [
  DiarioEntry(data: DateTime.now().subtract(const Duration(hours: 3)), titulo: 'Passeio no parque', nota: '30 min de caminhada e água.', icone: Icons.park, petId: 'thor'),
  DiarioEntry(data: DateTime.now().subtract(const Duration(days: 1)), titulo: 'Banho', nota: 'Shampoo hipoalergênico.', icone: Icons.shower, petId: 'thor'),
  DiarioEntry(data: DateTime.now().subtract(const Duration(hours: 5)), titulo: 'Caminhada', nota: '15 min de brincadeira.', icone: Icons.park, petId: 'luna'),
];

final List<EventoAgenda> _agenda = [
  EventoAgenda(quando: DateTime.now().add(const Duration(days: 2, hours: 3)), titulo: 'Consulta veterinária', local: 'Clínica Amigo Pet', icone: Icons.local_hospital, petId: 'thor'),
  EventoAgenda(quando: DateTime.now().subtract(const Duration(days: 1)), titulo: 'Tosa', local: 'PetShop Felicidade', icone: Icons.cut, petId: 'thor'),
  EventoAgenda(quando: DateTime.now().add(const Duration(days: 5)), titulo: 'Exame de rotina', local: 'Clínica Gatos & Cia', icone: Icons.local_hospital, petId: 'luna'),
];

final List<VacinaItem> _vacinas = [
  VacinaItem(nome: 'V10', aplicadaEm: DateTime.now().subtract(const Duration(days: 180)), proxima: DateTime.now().add(const Duration(days: 185)), petId: 'thor'),
  VacinaItem(nome: 'Antirrábica', aplicadaEm: DateTime.now().subtract(const Duration(days: 360)), proxima: DateTime.now().add(const Duration(days: 5)), petId: 'thor'),
  VacinaItem(nome: 'V4', aplicadaEm: DateTime.now().subtract(const Duration(days: 200)), proxima: DateTime.now().add(const Duration(days: 165)), petId: 'luna'),
];

// ===== WIDGETS REUTILIZÁVEIS =====
class SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  const SectionTitle(this.text, {super.key, this.icon = Icons.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class CardTile extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final void Function()? onTap;
  const CardTile({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

// ===== PÁGINAS =====
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Pet? _selectedPet;

  @override
  void initState() {
    super.initState();
    _selectedPet = _pets.first;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // O seletor de pets ou detalhes do pet selecionado
        if (_selectedPet != null)
          _buildPetDetailsCard(context, _selectedPet!)
        else
          _buildPetSelectorCard(context),

        // Seção de compromissos próximos, visível em ambos os casos
        const SectionTitle('Compromissos Próximos', icon: Icons.event),
        ..._buildHojeSectionAllPets(context),

        // As outras seções só aparecem se um pet estiver selecionado
        if (_selectedPet != null)
          ...[
            const SectionTitle('Próximas Vacinas', icon: Icons.vaccines),
            ..._buildVacinasSection(context, _selectedPet!),
            const SectionTitle('Últimos registros do diário', icon: Icons.edit_note),
            ..._buildDiarioSection(context, _selectedPet!),
            const SizedBox(height: 24),
          ],
      ],
    );
  }

  Widget _buildPetSelectorCard(BuildContext context) {
    final hasPets = _pets.isNotEmpty;
    final text = hasPets ? 'Selecione seu pet' : 'Adicione seu pet';

    return CardTile(
      onTap: () => _showPetSelectionSheet(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Text(text, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildPetDetailsCard(BuildContext context, Pet pet) {
    return CardTile(
      child: Row(
        children: [
          InkWell(
            onTap: () => _showPetSelectionSheet(context),
            borderRadius: BorderRadius.circular(34),
            child: CircleAvatar(
              radius: 34,
              child: Icon(pet.icone, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.nome, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('${pet.raca} • ${pet.idade} anos • ${pet.peso} kg', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () => _openAddDiario(context, petId: pet.id),
            child: const Row(children: [Icon(Icons.add), SizedBox(width: 6), Text('Novo registro')]),
          ),
        ],
      ),
    );
  }

  void _showPetSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Selecione um pet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ..._pets.map((pet) {
              return ListTile(
                leading: CircleAvatar(child: Icon(pet.icone)),
                title: Text(pet.nome),
                subtitle: Text('${pet.raca} • ${pet.idade} anos'),
                onTap: () {
                  setState(() {
                    _selectedPet = pet;
                  });
                  Navigator.pop(ctx);
                },
                selected: _selectedPet?.id == pet.id,
              );
            }),
            if (_pets.isEmpty)
              const ListTile(
                title: Text('Nenhum pet encontrado.'),
                subtitle: Text('Adicione um pet para começar.'),
              ),
          ],
        );
      },
    );
  }

  // Novo método para exibir compromissos de todos os pets
  List<Widget> _buildHojeSectionAllPets(BuildContext context) {
    final proximosEventos = _agenda.where((e) => e.quando.isAfter(DateTime.now())).toList();
    proximosEventos.sort((a, b) => a.quando.compareTo(b.quando)); // Ordena por data

    if (proximosEventos.isEmpty) {
      return [const CardTile(child: Text('Sem eventos próximos. 🎉'))];
    }

    return proximosEventos.take(3).map((e) {
      final pet = _pets.firstWhere((p) => p.id == e.petId);
      return CardTile(
        child: Row(children: [
          Icon(e.icone),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${_fmtDataHora(e.quando)} • ${e.local} (${pet.nome})')
          ])),
        ]),
      );
    }).toList();
  }

  List<Widget> _buildVacinasSection(BuildContext context, Pet pet) {
    final proximasVacinas = _vacinas.where((v) => v.petId == pet.id && v.proxima != null && v.proxima!.isAfter(DateTime.now())).toList();
    proximasVacinas.sort((a, b) => a.proxima!.compareTo(b.proxima!));
    if (proximasVacinas.isEmpty) {
      return [const CardTile(child: Text('Sem vacinas próximas.'))];
    }
    return proximasVacinas.take(3).map((v) {
      final isOverdue = v.proxima != null && v.proxima!.isBefore(DateTime.now());
      final color = isOverdue ? Colors.red.shade700 : null;

      return CardTile(
        child: Row(
          children: [
            Icon(Icons.vaccines, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.nome, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Próxima: ${_fmtData(v.proxima)} (${pet.nome})',
                    style: TextStyle(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildDiarioSection(BuildContext context, Pet pet) {
    final petDiario = _diario.where((d) => d.petId == pet.id).take(3).toList();
    if (petDiario.isEmpty) {
      return [const CardTile(child: Text('Sem registros recentes.'))];
    }
    return petDiario.map((d) => CardTile(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(d.icone),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(d.nota),
          const SizedBox(height: 6),
          Text('${_fmtDataHora(d.data)} (${pet.nome})', style: Theme.of(context).textTheme.bodySmall),
        ])),
      ]),
    )).toList();
  }
}

class DiarioPage extends StatefulWidget {
  const DiarioPage({super.key});

  @override
  State<DiarioPage> createState() => _DiarioPageState();
}

class _DiarioPageState extends State<DiarioPage> {
  void _deleteDiarioEntry(DiarioEntry entry) {
    setState(() {
      _diario.remove(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SectionTitle('Registros do diário', icon: Icons.edit_note),
          ..._diario.map((d) => CardTile(
            child: ListTile(
              leading: Icon(d.icone),
              title: Text(d.titulo),
              subtitle: Text('${_fmtDataHora(d.data)}\n${d.nota}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteDiarioEntry(d),
              ),
            ),
          )),
          if (_diario.isEmpty) const CardTile(child: Text('Sem registros ainda.')),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDiario(context, onAdded: () => setState(() {})),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  void _deleteAgendaEvent(EventoAgenda event) {
    setState(() {
      _agenda.remove(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        const SectionTitle('Compromissos', icon: Icons.event),
        ..._agenda.map((e) {
          final isOverdue = e.quando.isBefore(DateTime.now());
          final color = isOverdue ? Colors.red.shade700 : null;

          return CardTile(
            child: ListTile(
              leading: Icon(e.icone, color: color),
              title: Text(e.titulo),
              subtitle: Text(
                '${_fmtDataHora(e.quando)} • ${e.local}',
                style: TextStyle(color: color),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteAgendaEvent(e),
              ),
            ),
          );
        }),
        if (_agenda.isEmpty) const CardTile(child: Text('Nada agendado.')),
        const SizedBox(height: 80),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddAgenda(context, onAdded: () => setState(() {})),
        icon: const Icon(Icons.add),
        label: const Text('Novo evento'),
      ),
    );
  }
}

class VacinasPage extends StatefulWidget {
  const VacinasPage({super.key});

  @override
  State<VacinasPage> createState() => _VacinasPageState();
}

class _VacinasPageState extends State<VacinasPage> {
  void _deleteVacina(VacinaItem vacina) {
    setState(() {
      _vacinas.remove(vacina);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        const SectionTitle('Carteira de Vacinação', icon: Icons.vaccines),
        ..._vacinas.map((v) {
          final isOverdue = v.proxima != null && v.proxima!.isBefore(DateTime.now());
          final color = isOverdue ? Colors.red.shade700 : null;

          return CardTile(
            child: ListTile(
              leading: Icon(Icons.vaccines, color: color),
              title: Text(v.nome),
              subtitle: Text(
                'Aplicada: ${_fmtData(v.aplicadaEm)}\nPróxima: ${_fmtData(v.proxima)}',
                style: TextStyle(color: color),
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteVacina(v),
              ),
            ),
          );
        }),
        if (_vacinas.isEmpty) const CardTile(child: Text('Nenhuma vacina cadastrada.')),
        const SizedBox(height: 80),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddVacina(context, onAdded: () => setState(() {})),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar vacina'),
      ),
    );
  }
}

class PerfilUsuarioPage extends ConsumerWidget {
  const PerfilUsuarioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authProvider.notifier);
    final user = Supabase.instance.client.auth.currentUser;
    
    final userName = user?.email?.split('@').first ?? 'Usuário';
    final userEmail = user?.email ?? 'N/A';

    return Scaffold(
      body: ListView(
        children: [
          const SectionTitle('Perfil do Usuário', icon: Icons.person),
          CardTile(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 12),
                Text(userName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(userEmail),
              ],
            ),
          ),
          const SectionTitle('Informações'),
          const CardTile(
            child: _InfoRow(label: 'Assinatura', value: 'Plano Gratuito'),
          ),
          const CardTile(
            child: _InfoRow(label: 'Último acesso', value: '15/08/2025'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await authNotifier.logout();
        },
        label: const Text('Sair'),
        icon: const Icon(Icons.logout),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

// ===== HELPERS =====
String _fmtData(DateTime? d) {
  if (d == null) return '-';
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final year = d.year.toString();
  return '$day/$month/$year';
}

String _fmtDataHora(DateTime d) {
  final dd = _fmtData(d);
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$dd às $hh:$mm';
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// ===== DIALOGS / FORMS =====
void _openAddDiario(BuildContext context, {String? petId, VoidCallback? onAdded}) {
  final titleCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  IconData selectedIcon = Icons.check_circle;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _FormSheet(
          title: 'Novo registro',
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título', prefixIcon: Icon(Icons.title))),
            const SizedBox(height: 8),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Descrição/nota', prefixIcon: Icon(Icons.notes)), maxLines: 3),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              for (final i in [Icons.pets, Icons.park, Icons.shower, Icons.pedal_bike, Icons.restaurant, Icons.medical_services])
                ChoiceChip(
                  label: Icon(i, size: 18),
                  selected: selectedIcon == i,
                  onSelected: (_) {
                    selectedIcon = i;
                    (ctx as Element).markNeedsBuild();
                  },
                ),
            ]),
          ],
          onSubmit: () {
            _diario.insert(0, DiarioEntry(data: DateTime.now(), titulo: titleCtrl.text.trim(), nota: noteCtrl.text.trim(), icone: selectedIcon, petId: petId ?? 'thor'));
            Navigator.pop(ctx);
            onAdded?.call();
          },
        ),
      );
    },
  );
}

void _openAddAgenda(BuildContext context, {String? petId, VoidCallback? onAdded}) {
  final titleCtrl = TextEditingController();
  final localCtrl = TextEditingController();
  DateTime selected = DateTime.now().add(const Duration(hours: 2));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _FormSheet(
          title: 'Novo evento',
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título', prefixIcon: Icon(Icons.title))),
            const SizedBox(height: 8),
            TextField(controller: localCtrl, decoration: const InputDecoration(labelText: 'Local', prefixIcon: Icon(Icons.place_outlined))),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule),
              const SizedBox(width: 8),
              Text(_fmtDataHora(selected)),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(context: ctx, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: selected);
                  if (date == null) return;
                  final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(selected));
                  if (time == null) return;
                  selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                  (ctx as Element).markNeedsBuild();
                },
                child: const Text('Escolher data/hora'),
              )
            ])
          ],
          onSubmit: () {
            // Adicionado: agendar notificação antes de adicionar ao array e fechar o modal
            final reminderDate = selected.subtract(const Duration(hours: 1));
            if (reminderDate.isAfter(DateTime.now())) {
              _scheduleNotification(
                'Lembrete de compromisso!',
                'Seu pet tem o compromisso "${titleCtrl.text.trim()}" em uma hora.',
                reminderDate,
                id: _agenda.length, // Usar um ID único
              );
            }
            _agenda.add(EventoAgenda(quando: selected, titulo: titleCtrl.text.trim(), local: localCtrl.text.trim(), petId: petId ?? 'thor'));
            Navigator.pop(ctx);
            onAdded?.call();
          },
        ),
      );
    },
  );
}

void _openAddVacina(BuildContext context, {String? petId, VoidCallback? onAdded}) {
  final nomeCtrl = TextEditingController();
  DateTime? aplicada;
  DateTime? proxima;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _FormSheet(
          title: 'Adicionar vacina',
          children: [
            TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome da vacina', prefixIcon: Icon(Icons.vaccines))),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.check_circle_outline),
              const SizedBox(width: 8),
              Text('Aplicada: ${_fmtData(aplicada)}'),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final d = await showDatePicker(context: ctx, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: DateTime.now());
                  if (d != null) {
                    aplicada = d;
                    (ctx as Element).markNeedsBuild();
                  }
                },
                child: const Text('Escolher'),
              )
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule_send_outlined),
              const SizedBox(width: 8),
              Text('Próxima: ${_fmtData(proxima)}'),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final d = await showDatePicker(context: ctx, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: DateTime.now());
                  if (d != null) {
                    proxima = d;
                    (ctx as Element).markNeedsBuild();
                  }
                },
                child: const Text('Escolher'),
              )
            ]),
          ],
          onSubmit: () {
            _vacinas.add(VacinaItem(nome: nomeCtrl.text.trim(), aplicadaEm: aplicada, proxima: proxima, petId: petId ?? 'thor'));
            Navigator.pop(ctx);
            onAdded?.call();
          },
        ),
      );
    },
  );
}

class _FormSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSubmit;
  const _FormSheet({required this.title, required this.children, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
          ]),
          const SizedBox(height: 8),
          ...children,
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: onSubmit, icon: const Icon(Icons.save), label: const Text('Salvar')),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// Funções de ajuda
Future<void> _scheduleNotification(String title, String body, DateTime scheduledDate, {int id = 0}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  // CORREÇÃO: Usando zonedSchedule para agendar notificações
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledDate, tz.local),
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}