// lib/features/auth/presentation/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_controller.dart';
import 'register_page.dart';

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
      // Profil/çağıran sayfaya geri dön
      Navigator.of(context).pop(true); // ← kritik satır
      // Router kullanacaksan:
      // context.go('/home');
    } else if (s.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.error!)));
      setState(() {});
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

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cs.outlineVariant),
    );
    final fieldFocused =
    fieldBorder.copyWith(borderSide: BorderSide(color: cs.primary, width: 2));

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
                      Center(
                        child: Image.asset(
                          'assets/images/sadece_amblem.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Kullanıcı adı
                      TextFormField(
                        controller: _username,
                        focusNode: _usernameFocus,
                        enabled: !state.loading,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Kullanıcı adı',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          border: fieldBorder,
                          enabledBorder: fieldBorder,
                          focusedBorder: fieldFocused,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
                      ),

                      const SizedBox(height: 12),

                      // Şifre
                      TextFormField(
                        controller: _password,
                        focusNode: _passwordFocus,
                        enabled: !state.loading,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
                            onPressed: state.loading
                                ? null
                                : () => setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: fieldBorder,
                          enabledBorder: fieldBorder,
                          focusedBorder: fieldFocused,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                        onFieldSubmitted: (_) => _onLogin(),
                      ),

                      // Şifremi unuttum
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: state.loading ? null : _onForgotPasswordTodo,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/fish.png',
                                width: 18,
                                height: 18,
                                errorBuilder: (_, __, ___) =>
                                const Text('🐟', style: TextStyle(fontSize: 16)),
                              ),
                              const SizedBox(width: 6),
                              const Text('Şifreni mi unuttun?'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Giriş yap
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(cs.onSurface),
                            foregroundColor:
                            const WidgetStatePropertyAll(Colors.white),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            textStyle: WidgetStatePropertyAll(
                              theme.textTheme.labelLarge?.copyWith(fontSize: 16),
                            ),
                          ),
                          onPressed: state.loading ? null : _onLogin,
                          child: state.loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : const Text('Giriş yap'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Google ile devam et
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: state.loading ? null : _onGoogleTodo,
                          icon: Image.asset(
                            'assets/icons/google.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.login, size: 18),
                          ),
                          label: const Text('Google ile devam et'),
                        ),
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
