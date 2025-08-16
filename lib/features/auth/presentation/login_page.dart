import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // debugPrint için
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soundconnectmobile/env/env.dart';
import 'package:soundconnectmobile/features/auth/presentation/login_controller.dart';

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
  bool _rememberMe = false;

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

    final s = ref.read(loginControllerProvider);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Giriş başarılı')));
      // TODO: go_router → context.go('/home');
    } else if (s.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.error!)));
      setState(() {});
    }
  }

  Future<void> _onGoogleSignIn() async {
    ref.read(loginControllerProvider.notifier).clearError();

    // Env’de client id yoksa kullanıcıyı bilgilendir.
    if (Env.googleWebClientId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Web Client ID tanımlı değil (GOOGLE_WEB_CLIENT_ID).')),
      );
      return;
    }

    try {
      // 1) Google hesabını seçtir (serverClientId şart)
      final googleUser = await GoogleSignIn(
        serverClientId: Env.googleWebClientId,
        // scopes: const ['email'], // istersen aç
      ).signIn();

      if (googleUser == null) {
        // kullanıcı iptal etti
        return;
      }

      // 2) Token’ları al
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google token alınamadı')),
        );
        return;
      }

      // Sadece teşhis için ilk 12 char logla
      debugPrint('Google ID Token (first12): ${idToken.substring(0, 12)}...');

      // 3) Backend’e gönder
      final ok =
      await ref.read(loginControllerProvider.notifier).googleSignIn(idToken);

      final s = ref.read(loginControllerProvider);
      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google giriş başarılı')),
        );
        // TODO: go_router → context.go('/home');
      } else if (s.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.error!)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google giriş hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // --- Input stilleri (sayfa özel) ---
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cs.outlineVariant),
    );
    final fieldFocused = fieldBorder.copyWith(
      borderSide: BorderSide(color: cs.primary, width: 2),
    );

    // --- LOGO (ortada) ---
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

    // --- Form ---
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kullanıcı adı
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
                FocusScope.of(context).requestFocus(_passwordFocus),
          ),

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
          const SizedBox(height: 12),

          // Remember + Forgot aynı satır
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: state.loading
                    ? null
                    : (v) => setState(() => _rememberMe = v ?? false),
              ),
              Text(
                'Beni hatırla',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: state.loading ? null : () {/* TODO */},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🐟 Balık ikonu
                    Image.asset(
                      'assets/icons/fish.png',
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Şifreni mi unuttun?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Login button (koyu)
          SizedBox(
            height: 52,
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(cs.onSurface),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
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

          const SizedBox(height: 18),

          // Or divider
          Row(
            children: [
              Expanded(
                  child: Divider(color: cs.outlineVariant, thickness: .8)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('veya',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(.6),
                      fontWeight: FontWeight.w500,
                    )),
              ),
              Expanded(
                  child: Divider(color: cs.outlineVariant, thickness: .8)),
            ],
          ),
          const SizedBox(height: 14),

          // Google button
          SizedBox(
            height: 52,
            child: OutlinedButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                side: WidgetStatePropertyAll(
                    BorderSide(color: cs.outlineVariant)),
                foregroundColor: WidgetStatePropertyAll(cs.onSurface),
              ),
              onPressed: state.loading ? null : _onGoogleSignIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/google.png', width: 20, height: 20),
                  const SizedBox(width: 10),
                  Text('Google ile devam et',
                      style: theme.textTheme.labelLarge),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );

    // Kart + spacing (üstte logo, altında form)
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

    // Alt link
    final footer = SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hesabın yok mu?",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withOpacity(.75),
                )),
            TextButton(
              onPressed: state.loading ? null : () {/* TODO: Register */},
              child: Text('Üye Ol',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.secondary, // Apricot vurgu
                  )),
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
