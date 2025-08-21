import 'package:flutter/material.dart';
import 'package:soundconnectmobile/features/auth/presentation/login/widgets/auth_styles.dart';

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
          decoration: AuthStyles.decoration(
            context: context,
            labelText: 'Kullanıcı adı',
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ).copyWith(
            fillColor: Colors.transparent, // 👈 sadece burada override
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
          decoration: AuthStyles.decoration(
            context: context,
            labelText: 'E-posta',
            prefixIcon: const Icon(Icons.alternate_email_rounded),
          ).copyWith(
            fillColor: Colors.transparent, // 👈 burası da saydam
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
