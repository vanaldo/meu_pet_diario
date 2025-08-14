import 'dart:async';
import 'package:flutter/material.dart';

import 'services/supabase_service.dart';
import 'services/auth_service.dart';

// Páginas (vamos implementar as UIs nos próximos passos)
import 'pages/login/login_page.dart';
import 'pages/register/register_page.dart';
import 'pages/home/home_page.dart';
import 'pages/pet_form/pet_form_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init(); // inicia Supabase (usa anon key do seu service)

  runApp(const MeuPetDiarioApp());
}

class MeuPetDiarioApp extends StatelessWidget {
  const MeuPetDiarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Pet Diário',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      // AuthGate decide a tela inicial com base na sessão
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const HomePage(),
        '/pet_form': (_) => const PetFormPage(),
      },
    );
  }
}

/// Observa o estado de autenticação e direciona para Login ou Home.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late StreamSubscription _sub;
  bool _ready = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();

    // Estado inicial
    _loggedIn = AuthService.I.isLoggedIn;
    _ready = true;

    // Ouve mudanças de sessão (login/logout/refresh)
    _sub = AuthService.I.onAuthStateChange().listen((event) {
      final session = SupabaseService.session;
      final isLogged = session != null;
      if (mounted) {
        setState(() => _loggedIn = isLogged);
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Decide qual tela renderizar com base na sessão
    if (_loggedIn) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
