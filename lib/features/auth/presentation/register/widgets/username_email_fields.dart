import 'package:flutter/material.dart';

class UsernameEmailFields extends StatelessWidget {
  final TextEditingController username;
  final TextEditingController email;
  final FocusNode usernameFocus;
  final FocusNode emailFocus;
  final VoidCallback onUsernameSubmitted;

  const UsernameEmailFields({
    super.key,
    required this.username,
    required this.email,
    required this.usernameFocus,
    required this.emailFocus,
    required this.onUsernameSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // USERNAME
        TextFormField(
          controller: username,
          focusNode: usernameFocus,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          decoration: const InputDecoration(
            labelText: 'Kullanıcı adı',
            hintText: 'kullanici_adi',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
          onFieldSubmitted: (_) => onUsernameSubmitted(),
        ),
        const SizedBox(height: 12),

        // EMAIL
        TextFormField(
          controller: email,
          focusNode: emailFocus,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'E-posta',
            hintText: 'ornek@mail.com',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Zorunlu';
            final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
            if (!emailRegex.hasMatch(v.trim())) return 'Geçerli bir e-posta girin';
            return null;
          },
        ),
      ],
    );
  }
}
