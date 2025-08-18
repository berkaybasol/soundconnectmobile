// lib/features/auth/presentation/verify_code_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'verify_code_controller.dart';

class VerifyCodePage extends ConsumerStatefulWidget {
  final String email;
  final int initialOtpTtlSeconds; // register dönüşünden gelir (opsiyonel)
  final VoidCallback? onVerified; // başarılı olunca yapılacak aksiyon (opsiyonel)

  const VerifyCodePage({
    super.key,
    required this.email,
    this.initialOtpTtlSeconds = 0,
    this.onVerified,
  });

  @override
  ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends ConsumerState<VerifyCodePage> {
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
      if (widget.onVerified != null) {
        widget.onVerified!.call();
      } else {
        Navigator.of(context).maybePop();
      }
    } else if (s.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.error!)),
      );
    }
  }

  Future<void> _onResend() async {
    await ref
        .read(verifyCodeControllerProvider.notifier)
        .resend(email: widget.email);

    final s = ref.read(verifyCodeControllerProvider);
    if (!mounted) return;

    if (s.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.message!)));
    }
    if (s.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(verifyCodeControllerProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final canResend = s.cooldownSeconds <= 0 && !s.resending && !s.verifying;

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
                      Text('E-posta: ${widget.email}',
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),

                      if (s.otpTtlSeconds > 0)
                        Text(
                          'Kodun geçerlilik süresi: ${s.otpTtlSeconds}s',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurface.withOpacity(.7)),
                        ),
                      const SizedBox(height: 16),

                      // 6 haneli kod input
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
                        enabled: !s.verifying,
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: s.verifying ? null : _onVerify,
                          child: s.verifying
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text('Doğrula'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Resend
                      if (s.cooldownSeconds > 0)
                        Text(
                          'Yeniden gönder için bekle: ${s.cooldownSeconds}s',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurface.withOpacity(.7)),
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
