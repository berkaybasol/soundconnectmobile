import 'package:flutter/material.dart';

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
      decoration: const InputDecoration(
        labelText: 'Rol',
        prefixIcon: Icon(Icons.badge_outlined),
      ),
      hint: const Text('Sizi nasıl tanıyalım?'),
      items: roles.entries
          .map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Bir rol seçin' : null,
    );
  }
}
