import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onComplete; // 6 hane olunca çağrılır

  const OtpInput({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: 6,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: const InputDecoration(
        labelText: '6 haneli kod',
        counterText: '',
        prefixIcon: Icon(Icons.vpn_key_rounded),
      ),
      validator: (v) {
        if (v == null || v.length != 6) return '6 haneli kod girin';
        return null;
      },
      enabled: enabled,
      onChanged: (v) {
        if (v.length == 6) onComplete();
      },
    );
  }
}
