import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final bool busy;                 // verifying || post flow
  final VoidCallback? onPressed;   // null ise disabled

  const SubmitButton({
    super.key,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        child: busy
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Text('Doğrula'),
      ),
    );
  }
}
