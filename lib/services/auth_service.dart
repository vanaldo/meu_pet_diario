import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Serviço de autenticação (email/senha) com Supabase.
/// - Suporta redirectTo (ngrok) para fluxos que precisem de callback (ex.: confirmação de e-mail).
/// - Mantém sessão automaticamente (o supabase_flutter já persiste a sessão).
///
/// Como passar o redirect por linha de comando:
/// flutter run \
///  --dart-define=SUPABASE_REDIRECT_URL=https://SEU-NGROK.ngrok-free.app/auth/callback
class AuthService {
  AuthService._();
  static final AuthService I = AuthService._();

  // redirectTo para fluxos de link (confirm email / magic link / reset)
  static const String _envRedirect =
      String.fromEnvironment('SUPABASE_REDIRECT_URL', defaultValue: '');
  static const String _fallbackRedirect =
      '  https://9cf10b857c2c.ngrok-free.app/auth/callback'; // ajuste se for usar

  SupabaseClient get _cli => SupabaseService.client;

  /// Stream para saber mudanças de sessão/usuario (login/logout/refresh).
  Stream<AuthState> onAuthStateChange() => _cli.auth.onAuthStateChange;

  /// Usuário atual (ou null)
  User? get currentUser => _cli.auth.currentUser;

  /// Está logado?
  bool get isLoggedIn => _cli.auth.currentSession != null;

  /// Cadastro com email/senha.
  /// Se o projeto exigir confirmação de e-mail, o Supabase envia o link para `redirectTo`.
  Future<User?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await SupabaseService.init();

    try {
      final redirectTo = _envRedirect.isNotEmpty ? _envRedirect : _fallbackRedirect;

      final res = await _cli.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: redirectTo,
        data: displayName == null ? null : {'full_name': displayName},
      );

      dev.log('signUp -> user: ${res.user?.id}, confirmationSent: ${res.user == null}',
          name: 'AuthService');

      // Em projetos com "Email confirmations" ON, res.session pode vir null até confirmar
      return res.user;
    } on AuthException catch (e) {
      // Erros "bonitos" do Supabase (ex.: email já cadastrado)
      throw Exception(_mapAuthMessage(e.message));
    } catch (e) {
      throw Exception('Erro ao cadastrar. Detalhes: $e');
    }
  }

  /// Login com email/senha.
  Future<Session> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await SupabaseService.init();

    try {
      final res = await _cli.auth.signInWithPassword(email: email, password: password);
      if (res.session == null) {
        throw Exception('Falha ao autenticar: sessão inválida.');
      }
      dev.log('signIn -> user: ${res.user?.id}', name: 'AuthService');
      return res.session!;
    } on AuthException catch (e) {
      throw Exception(_mapAuthMessage(e.message));
    } catch (e) {
      throw Exception('Erro ao entrar. Detalhes: $e');
    }
  }

  /// Logout
  Future<void> signOut() async {
    await SupabaseService.init();
    try {
      await _cli.auth.signOut();
      dev.log('signOut -> ok', name: 'AuthService');
    } on AuthException catch (e) {
      throw Exception(_mapAuthMessage(e.message));
    } catch (e) {
      throw Exception('Erro ao sair. Detalhes: $e');
    }
  }

  /// Envio de e-mail para redefinição de senha.
  /// O link usará o redirectTo configurado.
  Future<void> sendPasswordResetEmail(String email) async {
    await SupabaseService.init();
    try {
      final redirectTo = _envRedirect.isNotEmpty ? _envRedirect : _fallbackRedirect;
      await _cli.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
      dev.log('sendPasswordResetEmail -> enviado para $email', name: 'AuthService');
    } on AuthException catch (e) {
      throw Exception(_mapAuthMessage(e.message));
    } catch (e) {
      throw Exception('Erro ao solicitar recuperação de senha. Detalhes: $e');
    }
  }

  /// Atualizar a senha do usuário logado (quando ele abriu o link de reset).
  Future<void> updatePassword(String newPassword) async {
    await SupabaseService.init();
    try {
      await _cli.auth.updateUser(UserAttributes(password: newPassword));
      dev.log('updatePassword -> ok', name: 'AuthService');
    } on AuthException catch (e) {
      throw Exception(_mapAuthMessage(e.message));
    } catch (e) {
      throw Exception('Erro ao atualizar senha. Detalhes: $e');
    }
  }

  /// Recarrega os dados do usuário.
  Future<User?> refreshUser() async {
    await SupabaseService.init();
    try {
      final user = await _cli.auth.getUser();
      dev.log('refreshUser -> ${user.user?.id}', name: 'AuthService');
      return user.user;
    } on AuthException catch (e) {
      throw Exception(_mapAuthMessage(e.message));
    } catch (e) {
      throw Exception('Erro ao atualizar usuário. Detalhes: $e');
    }
  }

  /// Mapeia mensagens comuns para PT-BR amigável.
  String _mapAuthMessage(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'Credenciais inválidas. Verifique e-mail e senha.';
    }
    if (m.contains('email rate limit exceeded')) {
      return 'Muitas tentativas. Aguarde alguns instantes.';
    }
    if (m.contains('signup disabled')) {
      return 'Cadastro desabilitado no momento.';
    }
    if (m.contains('user already registered') || m.contains('already registered')) {
      return 'E-mail já cadastrado.';
    }
    if (m.contains('email not confirmed')) {
      return 'E-mail ainda não confirmado. Verifique sua caixa de entrada.';
    }
    return msg; // fallback
  }
}
