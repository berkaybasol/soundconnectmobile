import 'package:flutter/material.dart';
import 'auth_styles.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final ValueChanged<String>? onSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.obscure,
    this.onToggleObscure,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      decoration: AuthStyles.decoration(
        context: context,
        labelText: 'Şifre',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
          onPressed: onToggleObscure,
          icon: Icon(
            obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          ),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
      onFieldSubmitted: onSubmitted,
    );
  }
}
