// lib/features/auth/presentation/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'register_controller.dart';
import 'verify_code_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _rePassword = TextEditingController();

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _rePasswordFocus = FocusNode();

  bool _obscure = true;
  bool _obscure2 = true;

  // USER kaldırıldı
  static const _roles = <String, String>{
    'ROLE_MUSICIAN': 'Müzisyen',
    'ROLE_VENUE': 'Mekan Sahibi',
    'ROLE_LISTENER': 'Dinleyici',
    'ROLE_STUDIO': 'Stüdyo',
    'ROLE_ORGANIZER': 'Organizatör',
    'ROLE_PRODUCER': 'Prodüktör',
  };

  // Başlangıçta seçim yok → hint görünsün
  String? _selectedRole;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _rePassword.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _rePasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final role = _selectedRole;
    if (role == null) return; // validator zaten uyarıyor

    final notifier = ref.read(registerControllerProvider.notifier);
    notifier.clearError();

    final outcome = await notifier.register(
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      rePassword: _rePassword.text,
      role: role,
    );

    if (!mounted) return;
    final s = ref.read(registerControllerProvider);

    if (outcome != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt alındı. Doğrulama kodunu gir.')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyCodePage(
            email: outcome.email,
            initialOtpTtlSeconds: outcome.otpTtlSeconds,
          ),
        ),
      );
    } else if (s.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.error!)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cs.outlineVariant),
    );
    final fieldFocused = fieldBorder.copyWith(
      borderSide: BorderSide(color: cs.primary, width: 2),
    );

    final header = Column(
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
      ],
    );

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _username,
            focusNode: _usernameFocus,
            enabled: !state.loading,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: 'Kullanıcı adı',
              hintText: 'kullanici_adi',
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
                FocusScope.of(context).requestFocus(_emailFocus),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            enabled: !state.loading,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'E-posta',
              hintText: 'ornek@mail.com',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Zorunlu';
              final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
              if (!emailRegex.hasMatch(v.trim())) {
                return 'Geçerli bir e-posta girin';
              }
              return null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_passwordFocus),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            focusNode: _passwordFocus,
            enabled: !state.loading,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Şifre',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
                onPressed:
                state.loading ? null : () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
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
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_rePasswordFocus),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rePassword,
            focusNode: _rePasswordFocus,
            enabled: !state.loading,
            obscureText: _obscure2,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Şifre (tekrar)',
              prefixIcon: const Icon(Icons.lock_reset_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure2 ? 'Şifreyi göster' : 'Şifreyi gizle',
                onPressed: state.loading
                    ? null
                    : () => setState(() => _obscure2 = !_obscure2),
                icon: Icon(
                  _obscure2 ? Icons.visibility_rounded : Icons.visibility_off_rounded,
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
            validator: (v) {
              if (v == null || v.isEmpty) return 'Zorunlu';
              if (v != _password.text) return 'Şifreler uyuşmuyor';
              return null;
            },
            onFieldSubmitted: (_) => _onRegister(),
          ),
          const SizedBox(height: 12),

          // DropdownButtonFormField ile validator + hint
          DropdownButtonFormField<String>(
            value: _selectedRole,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Rol',
              prefixIcon: const Icon(Icons.badge_outlined),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            hint: const Text('Sizi nasıl tanıyalım?'),
            items: _roles.entries.map((e) {
              return DropdownMenuItem<String>(
                value: e.key,
                child: Text(e.value),
              );
            }).toList(),
            onChanged: state.loading
                ? null
                : (v) => setState(() => _selectedRole = v),
            validator: (v) => v == null ? 'Bir rol seçin' : null,
          ),

          if (_selectedRole == 'ROLE_VENUE') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mekan Başvurusu',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 8),
                  Text(
                    'Kayıt sonrası başvuru akışına yönlendirileceksin.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(.7),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(cs.onSurface),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                textStyle: WidgetStatePropertyAll(
                  theme.textTheme.labelLarge?.copyWith(fontSize: 16),
                ),
              ),
              onPressed: state.loading ? null : _onRegister,
              child: state.loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Üye ol'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              form,
            ],
          ),
        ),
      ),
    );

    final footer = SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hesabın var mı?",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withOpacity(.75),
              ),
            ),
            TextButton(
              onPressed: state.loading ? null : () {
                Navigator.of(context).maybePop();
              },
              child: Text(
                'Giriş Yap',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: card,
        ),
      ),
      bottomNavigationBar: footer,
    );
  }
}
