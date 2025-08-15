import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provedor para o estado de autenticação
final authProvider = StreamProvider<AuthState>((ref) {
  // Retorna o stream de eventos de autenticação do Supabase
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Provedor para checar se o usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.event == AuthChangeEvent.signedIn,
    orElse: () => false,
  );
});

// Provedor para o usuário logado
final userProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => null,
  );
});