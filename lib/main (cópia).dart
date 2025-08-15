// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meu_pet_diario/providers/auth_provider.dart';
import 'package:meu_pet_diario/screens/login_screen.dart';
import 'package:meu_pet_diario/screens/pet_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Substitua 'SUA_URL_SUPABASE' e 'SUA_KEY_ANON' pelos seus valores
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
    const PerfilPetPage(),
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
class DiarioEntry {
  final DateTime data;
  final String titulo;
  final String nota;
  final IconData icone;
  DiarioEntry({required this.data, required this.titulo, required this.nota, this.icone = Icons.check_circle});
}

class EventoAgenda {
  final DateTime quando;
  final String titulo;
  final String local;
  final IconData icone;
  EventoAgenda({required this.quando, required this.titulo, required this.local, this.icone = Icons.event});
}

class VacinaItem {
  final String nome;
  final DateTime? aplicadaEm;
  final DateTime? proxima;
  VacinaItem({required this.nome, this.aplicadaEm, this.proxima});
}

// ===== DADOS MOCK =====
final List<DiarioEntry> _diario = [
  DiarioEntry(data: DateTime.now().subtract(const Duration(hours: 3)), titulo: 'Passeio no parque', nota: '30 min de caminhada e água.' , icone: Icons.park),
  DiarioEntry(data: DateTime.now().subtract(const Duration(days: 1)), titulo: 'Banho', nota: 'Shampoo hipoalergênico.' , icone: Icons.shower),
];

final List<EventoAgenda> _agenda = [
  EventoAgenda(quando: DateTime.now().add(const Duration(days: 2, hours: 3)), titulo: 'Consulta veterinária', local: 'Clínica Amigo Pet', icone: Icons.local_hospital),
  EventoAgenda(quando: DateTime.now().add(const Duration(days: 15)), titulo: 'Tosa', local: 'PetShop Felicidade', icone: Icons.cut),
];

final List<VacinaItem> _vacinas = [
  VacinaItem(nome: 'V10', aplicadaEm: DateTime.now().subtract(const Duration(days: 180)), proxima: DateTime.now().add(const Duration(days: 185))),
  VacinaItem(nome: 'Antirrábica', aplicadaEm: DateTime.now().subtract(const Duration(days: 360)), proxima: DateTime.now().add(const Duration(days: 5))),
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
  const CardTile({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// ===== PÁGINAS =====
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todayAgenda = _agenda.where((e) => _isSameDay(e.quando, DateTime.now())).toList();
    final proximasVacinas = _vacinas.where((v) => v.proxima != null && v.proxima!.isBefore(DateTime.now().add(const Duration(days: 30)))).toList();

    return ListView(
      children: [
        const SectionTitle('Meu pet', icon: Icons.pets),
        CardTile(
          child: Row(
            children: [
              const CircleAvatar(radius: 34, child: Icon(Icons.pets, size: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Thor', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('SRD • 3 anos • 12,5 kg', style: Theme.of(context).textTheme.bodyMedium),
                ]),
              ),
              FilledButton.tonal(
                onPressed: () => _openAddDiario(context),
                child: const Row(children: [Icon(Icons.add), SizedBox(width: 6), Text('Novo registro')]),
              ),
            ],
          ),
        ),

        const SectionTitle('Hoje'),
        if (todayAgenda.isEmpty)
          const CardTile(child: Text('Sem eventos para hoje. 👌'))
        else
          ...todayAgenda.map((e) => CardTile(
                child: Row(children: [
                  Icon(e.icone),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.titulo, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${_fmtDataHora(e.quando)} • ${e.local}')
                  ])),
                ]),
              )),

        const SectionTitle('Próximas vacinas'),
        if (proximasVacinas.isEmpty)
          const CardTile(child: Text('Sem vacinas próximas.'))
        else
          ...proximasVacinas.map((v) => CardTile(
                child: Row(children: [
                  const Icon(Icons.vaccines),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v.nome, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Próxima: ${_fmtData(v.proxima)}'),
                  ])),
                ]),
              )),

        const SectionTitle('Últimos registros do diário'),
        ..._diario.take(3).map((d) => CardTile(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(d.icone),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.titulo, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(d.nota),
                  const SizedBox(height: 6),
                  Text(_fmtDataHora(d.data), style: Theme.of(context).textTheme.bodySmall),
                ])),
              ]),
            )),
        const SizedBox(height: 24),
      ],
    );
  }
}

class DiarioPage extends StatefulWidget {
  const DiarioPage({super.key});

  @override
  State<DiarioPage> createState() => _DiarioPageState();
}

class _DiarioPageState extends State<DiarioPage> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        const SectionTitle('Compromissos', icon: Icons.event),
        ..._agenda.map((e) => CardTile(
              child: ListTile(
                leading: Icon(e.icone),
                title: Text(e.titulo),
                subtitle: Text('${_fmtDataHora(e.quando)} • ${e.local}'),
              ),
            )),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        const SectionTitle('Carteira de Vacinação', icon: Icons.vaccines),
        ..._vacinas.map((v) => CardTile(
              child: ListTile(
                leading: const Icon(Icons.vaccines),
                title: Text(v.nome),
                subtitle: Text('Aplicada: ${_fmtData(v.aplicadaEm)}\nPróxima: ${_fmtData(v.proxima)}'),
                isThreeLine: true,
              ),
            )),
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

class PerfilPetPage extends ConsumerWidget { // Mudança aqui: de StatelessWidget para ConsumerWidget
  const PerfilPetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authProvider.notifier); // Adicionei esta linha

    return Scaffold(
      body: ListView(
        children: [
          const SectionTitle('Perfil do Pet', icon: Icons.pets),
          CardTile(
            child: Column(
              children: [
                const CircleAvatar(radius: 44, child: Icon(Icons.pets, size: 40)),
                const SizedBox(height: 12),
                Text('Thor', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('SRD • 3 anos • Macho'),
              ],
            ),
          ),
          const SectionTitle('Informações'),
          const CardTile(child: _InfoRow(label: 'Peso atual', value: '12,5 kg')),
          const CardTile(child: _InfoRow(label: 'Castrado', value: 'Sim')),
          const CardTile(child: _InfoRow(label: 'Microchip', value: '000123456789')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended( // Adicionei o botão aqui
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
void _openAddDiario(BuildContext context, {VoidCallback? onAdded}) {
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
            _diario.insert(0, DiarioEntry(data: DateTime.now(), titulo: titleCtrl.text.trim(), nota: noteCtrl.text.trim(), icone: selectedIcon));
            Navigator.pop(ctx);
            onAdded?.call();
          },
        ),
      );
    },
  );
}

void _openAddAgenda(BuildContext context, {VoidCallback? onAdded}) {
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
            _agenda.add(EventoAgenda(quando: selected, titulo: titleCtrl.text.trim(), local: localCtrl.text.trim()));
            Navigator.pop(ctx);
            onAdded?.call();
          },
        ),
      );
    },
  );
}

void _openAddVacina(BuildContext context, {VoidCallback? onAdded}) {
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
            _vacinas.add(VacinaItem(nome: nomeCtrl.text.trim(), aplicadaEm: aplicada, proxima: proxima));
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