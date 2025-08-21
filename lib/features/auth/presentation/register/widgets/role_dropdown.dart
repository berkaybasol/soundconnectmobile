import 'package:flutter/material.dart';
import 'package:soundconnectmobile/features/auth/presentation/login/widgets/auth_styles.dart';

class RoleDropdown extends StatelessWidget {
  final Map<String, String> roles;
  final String? value;
  final ValueChanged<String?> onChanged;

  const RoleDropdown({
    super.key,
    required this.roles,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: AuthStyles.decoration(
        context: context,
        labelText: 'Rol',
        prefixIcon: const Icon(Icons.badge_outlined),
      ).copyWith(fillColor: Colors.transparent),
      hint: const Text('Sizi nasıl tanıyalım?'),
      items: roles.entries
          .map((e) =>
          DropdownMenuItem<String>(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Bir rol seçin' : null,
    );
  }
}
