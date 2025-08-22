import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // 🔸 eklendi

import 'login_controller.dart';
import '../register/register_page.dart';

// widgets
import 'widgets/sc_logo.dart';
import 'widgets/username_field.dart';
import 'widgets/password_field.dart';
import 'widgets/forgot_password_button.dart';
import 'widgets/login_button.dart';
import 'widgets/google_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(loginControllerProvider.notifier).clearError();

    final ok = await ref
        .read(loginControllerProvider.notifier)
        .login(_username.text.trim(), _password.text);

    if (!mounted) return;
    final s = ref.read(loginControllerProvider);

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Giriş başarılı')));
      // 🔸 Router ile hedefe gönder (guard zinciriyle uyumlu)
      context.go('/backstage/musician/profile');
    } else if (s.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.error!)));
      setState(() {}); // hata yazısı tetiklemek için
    }
  }

  void _onGoogleTodo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google ile giriş yakında (TODO)')),
    );
  }

  void _onForgotPasswordTodo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şifre sıfırlama yakında 🐟')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const SCLogo(),
                      const SizedBox(height: 16),

                      UsernameField(
                        controller: _username,
                        focusNode: _usernameFocus,
                        enabled: !state.loading,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),

                      const SizedBox(height: 12),

                      PasswordField(
                        controller: _password,
                        focusNode: _passwordFocus,
                        enabled: !state.loading,
                        obscure: _obscure,
                        onToggleObscure: state.loading
                            ? null
                            : () => setState(() => _obscure = !_obscure),
                        onSubmitted: (_) => _onLogin(),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ForgotPasswordButton(
                          onPressed: state.loading ? null : _onForgotPasswordTodo,
                        ),
                      ),

                      const SizedBox(height: 8),

                      LoginButton(
                        loading: state.loading,
                        onPressed: state.loading ? null : _onLogin,
                      ),

                      const SizedBox(height: 12),

                      GoogleButton(
                        loading: state.loading,
                        onPressed: state.loading ? null : _onGoogleTodo,
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Hesabın yok mu?",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface.withOpacity(.75),
                            ),
                          ),
                          TextButton(
                            onPressed: state.loading
                                ? null
                                : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Üye Ol',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
