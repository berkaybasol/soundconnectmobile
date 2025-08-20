import 'package:flutter/material.dart';

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
      decoration: const InputDecoration(
        labelText: 'Kullanıcı adı',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
      onFieldSubmitted: onSubmitted,
    );
  }
}
