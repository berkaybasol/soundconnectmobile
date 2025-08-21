// lib/features/home/presentation/backstage/backstage_home_page.dart
import 'package:flutter/material.dart';
import 'widgets/backstage_app_bar.dart';
import 'widgets/backstage_bottom_bar.dart';

class BackstageHomePage extends StatelessWidget {
  final Set<String> roles;
  const BackstageHomePage({super.key, required this.roles});

  bool get isMusician => roles.contains('ROLE_MUSICIAN');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Eğer sadece ROLE_LISTENER varsa MainStage'e dön
    if (roles.length == 1 && roles.contains('ROLE_LISTENER')) {
      return const _RedirectToMainStage();
    }

    return Scaffold(
      appBar: const BackstageAppBar(),
      body: Container(
        color: cs.surface,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isMusician
                          ? 'Backstage — LOADING..'
                          : 'Backstage — Aktör ana görünüm',
                      style: TextStyle(color: cs.onSurface),
                    ),
                    const SizedBox(height: 800),
                    Text('LOADING..',
                        style: TextStyle(color: cs.onSurface.withOpacity(.6))),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),
      bottomNavigationBar: const BackstageBottomBar(),
    );
  }
}

class _RedirectToMainStage extends StatelessWidget {
  const _RedirectToMainStage();

  @override
  Widget build(BuildContext context) {
    // Minimal fallback; gerçekte router ile yönlendirebilirsin
    return const Scaffold(
      body: Center(child: Text('MainStage’e yönlendiriliyor...')),
    );
  }
}
