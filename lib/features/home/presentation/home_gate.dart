// lib/features/home/presentation/home_gate.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';

import 'mainstage/mainstage_home_page.dart';
import 'backstage/backstage_home_page.dart';

class HomeGate extends ConsumerWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final roles = _rolesFromJwt(token);
    final isListener = roles.contains('ROLE_LISTENER');
    return isListener ? const MainStageHomePage() : BackstageHomePage(roles: roles);
  }

  Set<String> _rolesFromJwt(String? token) {
    try {
      if (token == null || token.isEmpty) return {};
      final parts = token.split('.');
      if (parts.length < 2) return {};
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = json.decode(payload) as Map<String, dynamic>;
      final raw = map['roles'];
      if (raw is List) return raw.map((e) => e.toString()).toSet();
      return {};
    } catch (_) {
      return {};
    }
  }
}
