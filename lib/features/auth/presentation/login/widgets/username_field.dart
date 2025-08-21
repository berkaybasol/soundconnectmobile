import 'package:flutter/material.dart';
import 'auth_styles.dart';

class UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  const UsernameField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      textInputAction: TextInputAction.next,
      decoration: AuthStyles.decoration(
        context: context,
        labelText: 'Kullanıcı adı',
        prefixIcon: const Icon(Icons.person_outline_rounded),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
      onFieldSubmitted: onSubmitted,
    );
  }
}
