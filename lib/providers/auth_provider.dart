// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meu_pet_diario/models/user_data.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final UserData? user;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    UserData? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: UserData(
          id: session.user.id,
          email: session.user.email ?? '',
        ),
      );
    }
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        password: password,
        email: email,
      );

      if (response.user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: UserData(
            id: response.user!.id,
            email: response.user!.email ?? '',
          ),
        );
        return null; // Retorna nulo em caso de sucesso
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Falha no login. Credenciais inválidas.',
        );
        return 'Falha no login. Credenciais inválidas.';
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return e.message;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro de conexão: $e',
      );
      return 'Erro de conexão: $e';
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    state = const AuthState();
  }
}