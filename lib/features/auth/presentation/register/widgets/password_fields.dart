import 'package:flutter/material.dart';
import 'package:soundconnectmobile/features/auth/presentation/login/widgets/auth_styles.dart';

class PasswordFields extends StatelessWidget {
  final TextEditingController password;
  final TextEditingController rePassword;
  final FocusNode passwordFocus;
  final FocusNode rePasswordFocus;
  final bool obscure1;
  final bool obscure2;
  final VoidCallback onToggle1;
  final VoidCallback onToggle2;
  final VoidCallback onDone;

  const PasswordFields({
    super.key,
    required this.password,
    required this.rePassword,
    required this.passwordFocus,
    required this.rePasswordFocus,
    required this.obscure1,
    required this.obscure2,
    required this.onToggle1,
    required this.onToggle2,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PASSWORD
        TextFormField(
          controller: password,
          focusNode: passwordFocus,
          obscureText: obscure1,
          textInputAction: TextInputAction.next,
          decoration: AuthStyles.decoration(
            context: context,
            labelText: 'Şifre',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              tooltip: obscure1 ? 'Şifreyi göster' : 'Şifreyi gizle',
              onPressed: onToggle1,
              icon: Icon(
                obscure1 ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              ),
            ),
          ).copyWith(fillColor: Colors.transparent),
          validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
        ),
        const SizedBox(height: 12),

        // REPASSWORD
        TextFormField(
          controller: rePassword,
          focusNode: rePasswordFocus,
          obscureText: obscure2,
          textInputAction: TextInputAction.done,
          decoration: AuthStyles.decoration(
            context: context,
            labelText: 'Şifre (tekrar)',
            prefixIcon: const Icon(Icons.lock_reset_rounded),
            suffixIcon: IconButton(
              tooltip: obscure2 ? 'Şifreyi göster' : 'Şifreyi gizle',
              onPressed: onToggle2,
              icon: Icon(
                obscure2 ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              ),
            ),
          ).copyWith(fillColor: Colors.transparent),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Zorunlu';
            if (v != password.text) return 'Şifreler uyuşmuyor';
            return null;
          },
          onFieldSubmitted: (_) => onDone(),
        ),
      ],
    );
  }
}
