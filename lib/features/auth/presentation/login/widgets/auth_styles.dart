import 'package:flutter/material.dart';

class AuthStyles {
  static OutlineInputBorder fieldBorder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cs.outlineVariant),
    );
  }

  static OutlineInputBorder fieldFocused(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return fieldBorder(context)
        .copyWith(borderSide: BorderSide(color: cs.primary, width: 2));
  }

  static InputDecoration decoration({
    required BuildContext context,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: fieldBorder(context),
      enabledBorder: fieldBorder(context),
      focusedBorder: fieldFocused(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
