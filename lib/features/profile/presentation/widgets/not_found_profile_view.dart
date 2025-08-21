// lib/features/profile/presentation/widgets/not_found_profile_view.dart
import 'package:flutter/material.dart';

class NotFoundProfileView extends StatelessWidget {
  final String message;
  final VoidCallback onCreate;
  const NotFoundProfileView({
    super.key,
    required this.message,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_outlined,
                size: 40, color: cs.onSurface.withOpacity(.9)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Profilini oluştur / düzenle'),
            ),
          ],
        ),
      ),
    );
  }
}
