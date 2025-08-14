import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço central de inicialização e acesso ao Supabase.
/// - Usa --dart-define para SUPABASE_URL e SUPABASE_ANON_KEY, se fornecidos.
/// - Caso não informe por --dart-define, usa os fallbacks abaixo.
/// - NÃO use service_role no cliente.
class SupabaseService {
  static bool _initialized = false;

  // 1) Lê as chaves via --dart-define (recomendado)
  static const String _envUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _envAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // 2) Fallback (edite para sua URL e ANON KEY, se preferir manter no código)
  //    ⚠️ Coloque aqui SOMENTE a ANON KEY (nunca service_role).
  static const String _fallbackUrl = 'https://qgfhmodijstlilfebcvl.supabase.co';
  static const String _fallbackAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFnZmhtb2RpanN0bGlsZmViY3ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2NjIzNTYsImV4cCI6MjA3MDIzODM1Nn0.lSkiMC9i6-DJBj2Jho8aKxkyJzWSeobTOEr26Q-m-1Y';

  static Future<void> init() async {
    if (_initialized) return;

    final url = _envUrl.isNotEmpty ? _envUrl : _fallbackUrl;
    final anonKey = _envAnonKey.isNotEmpty ? _envAnonKey : _fallbackAnonKey;

    // Só valida vazio/placeholder
    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Supabase não configurado: defina SUPABASE_URL e SUPABASE_ANON_KEY via --dart-define '
        'ou preencha os fallbacks em supabase_service.dart (use ANON KEY).',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      // debug: true,
    );

    _initialized = true;
    dev.log('Supabase inicializado', name: 'SupabaseService');
  }

  static SupabaseClient get client => Supabase.instance.client;
  static Session? get session => client.auth.currentSession;
  static User? get user => client.auth.currentUser;
}
