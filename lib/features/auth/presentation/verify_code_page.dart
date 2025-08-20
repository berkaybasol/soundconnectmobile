// lib/features/auth/presentation/verify_code_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'verify_code_controller.dart';
import 'login_controller.dart';

import 'models/venue_application_draft.dart';
import 'package:soundconnectmobile/core/error/ui_error_mapper.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';
import 'package:soundconnectmobile/core/network/api_paths.dart';

// Onboarding sayfaları
import 'package:soundconnectmobile/features/onboarding/musician_onboarding_page.dart';
import 'package:soundconnectmobile/features/onboarding/listener_onboarding_page.dart';
import 'package:soundconnectmobile/features/onboarding/organizer_onboarding_page.dart';
import 'package:soundconnectmobile/features/onboarding/producer_onboarding_page.dart';
import 'package:soundconnectmobile/features/onboarding/studio_onboarding_page.dart';

class VerifyCodePage extends ConsumerStatefulWidget {
  final String email;
  final int initialOtpTtlSeconds;
  final VoidCallback? onVerified;

  final VenueApplicationDraft? venueDraft;
  final String? usernameForAutoLogin;
  final String? passwordForAutoLogin;

  const VerifyCodePage({
    super.key,
    required this.email,
    this.initialOtpTtlSeconds = 0,
    this.onVerified,
    this.venueDraft,
    this.usernameForAutoLogin,
    this.passwordForAutoLogin,
  });

  @override
  ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends ConsumerState<VerifyCodePage> {
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _postFlowRan = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialOtpTtlSeconds > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(verifyCodeControllerProvider.notifier)
            .seedFromRegister(otpTtlSeconds: widget.initialOtpTtlSeconds);
      });
    }
    _codeCtrl.addListener(_maybeAutoSubmit);
  }

  @override
  void dispose() {
    _codeCtrl.removeListener(_maybeAutoSubmit);
    _codeCtrl.dispose();
    super.dispose();
  }

  void _maybeAutoSubmit() {
    if (_codeCtrl.text.length == 6) {
      _onVerify();
    }
  }

  Future<void> _onVerify() async {
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(verifyCodeControllerProvider.notifier)
        .verify(email: widget.email, code: _codeCtrl.text);

    final s = ref.read(verifyCodeControllerProvider);
    if (!mounted) return;

    if (s.verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta doğrulandı!')),
      );
      await _runPostVerifyFlow();
    } else if (s.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.error!)),
      );
    }
  }

  Future<void> _runPostVerifyFlow() async {
    if (_postFlowRan) return;
    _postFlowRan = true;
    setState(() => _busy = true);

    try {
      // 1) AUTO LOGIN
      String? token;
      if ((widget.usernameForAutoLogin?.isNotEmpty ?? false) &&
          (widget.passwordForAutoLogin?.isNotEmpty ?? false)) {
        final ok = await ref
            .read(loginControllerProvider.notifier)
            .login(widget.usernameForAutoLogin!, widget.passwordForAutoLogin!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ok ? 'Giriş yapıldı' : 'Giriş başarısız')),
          );
        }

        // login başarılıysa token RAM'de authTokenProvider’da mevcut
        token = ref.read(authTokenProvider);
      }

      // 2) VENUE APPLICATION CREATE (opsiyonel)
      if (widget.venueDraft != null) {
        final body = widget.venueDraft!.toCreateBody();
        final dio = ref.read(dioProvider);
        final res = await dio.post(ApiPaths.userVenueApplicationsCreate, data: body);
        final ok = (res.data is Map) && (res.data['success'] == true);

        if (mounted) {
          final msg = (res.data is Map && res.data['message'] != null)
              ? res.data['message'].toString()
              : (ok ? 'Mekan başvurun alındı 🎉' : 'Başvuru sırasında bir sorun oluştu');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      }

      // 3) ROLE’E GÖRE YÖNLENDİRME
      if (token != null && mounted) {
        final role = _extractRole(token);
        if (role != null) {
          switch (role) {
            case "ROLE_MUSICIAN":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MusicianOnboardingPage()),
              );
              break;
            case "ROLE_LISTENER":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ListenerOnboardingPage()),
              );
              break;
            case "ROLE_ORGANIZER":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OrganizerOnboardingPage()),
              );
              break;
            case "ROLE_PRODUCER":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProducerOnboardingPage()),
              );
              break;
            case "ROLE_STUDIO":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudioOnboardingPage()),
              );
              break;
            case "ROLE_VENUE":
            // Venue onboarding daha sonra eklenecek.
              break;
          }
        }
      }

      // 4) Callback
      widget.onVerified?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UiErrorMapper.humanize(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// JWT içinden "roles" alanını al
  String? _extractRole(String token) {
    try {
      final parts = token.split(".");
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = json.decode(payload) as Map<String, dynamic>;
      final roles = map["roles"];
      if (roles is List && roles.isNotEmpty) {
        return roles.first.toString();
      }
    } catch (_) {}
    return null;
  }

  Future<void> _onResend() async {
    await ref.read(verifyCodeControllerProvider.notifier).resend(email: widget.email);

    final s = ref.read(verifyCodeControllerProvider);
    if (!mounted) return;

    if (s.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.message!)));
    }
    if (s.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(verifyCodeControllerProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final canResend = s.cooldownSeconds <= 0 && !s.resending && !s.verifying && !_busy;

    return Scaffold(
      appBar: AppBar(title: const Text('Doğrulama Kodu')),
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
                      Text('E-posta: ${widget.email}', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),

                      if (s.otpTtlSeconds > 0)
                        Text(
                          'Kodun geçerlilik süresi: ${s.otpTtlSeconds}s',
                          style:
                          theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(.7)),
                        ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _codeCtrl,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          labelText: '6 haneli kod',
                          counterText: '',
                          prefixIcon: Icon(Icons.vpn_key_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.length != 6) {
                            return '6 haneli kod girin';
                          }
                          return null;
                        },
                        enabled: !s.verifying && !_busy,
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: (s.verifying || _busy) ? null : _onVerify,
                          child: (s.verifying || _busy)
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text('Doğrula'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (s.cooldownSeconds > 0)
                        Text(
                          'Yeniden gönder için bekle: ${s.cooldownSeconds}s',
                          textAlign: TextAlign.center,
                          style:
                          theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(.7)),
                        )
                      else
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: canResend ? _onResend : null,
                            child: s.resending
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Text('Kodu yeniden gönder'),
                          ),
                        ),

                      if (s.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          s.error!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.error, fontWeight: FontWeight.w600),
                        ),
                      ],
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
