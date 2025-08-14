import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
    if (!ok) return 'E-mail inválido';
    return null;
  }

  String? _validatePass(String? v) {
    if (v == null || v.isEmpty) return 'Informe a senha';
    if (v.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  Future<void> _doLogin() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return;

    setState(() => _loading = true);
    try {
      await AuthService.I.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;
      // Vai para Home e remove a pilha anterior
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(Icons.pets, size: 64),
                    const SizedBox(height: 12),
                    const Text(
                      'Meu Pet Diário',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),

                    // E-mail
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                      enabled: !_loading,
                    ),
                    const SizedBox(height: 12),

                    // Senha
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: _loading ? null : () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: _validatePass,
                      enabled: !_loading,
                    ),
                    const SizedBox(height: 20),

                    // Botão Entrar
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _loading ? null : _doLogin,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Link para cadastro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não tem conta?'),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.of(context).pushNamed('/register'),
                          child: const Text('Criar conta'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    // Opcional: Esqueci minha senha
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              final email = _emailCtrl.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Informe seu e-mail para recuperar a senha.'),
                                  ),
                                );
                                return;
                              }
                              try {
                                await AuthService.I.sendPasswordResetEmail(email);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Enviamos um link de redefinição para seu e-mail.'),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                      child: const Text('Esqueci minha senha'),
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
