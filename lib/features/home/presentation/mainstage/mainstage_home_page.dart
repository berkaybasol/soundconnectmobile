// lib/features/home/presentation/mainstage/mainstage_home_page.dart
import 'package:flutter/material.dart';
import 'widgets/mainstage_app_bar.dart';
import 'widgets/mainstage_bottom_bar.dart';

class MainStageHomePage extends StatelessWidget {
  const MainStageHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const MainStageAppBar(),
      body: Container(
        color: cs.surface,
        child: CustomScrollView(
          slivers: const [
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _MainStageContent(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),
      bottomNavigationBar: const MainStageBottomBar(),
    );
  }
}

class _MainStageContent extends StatelessWidget {
  const _MainStageContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('MainStage — Dinleyici akışı burada',
            style: TextStyle(color: cs.onSurface)),
        const SizedBox(height: 800),
        Text('Scroll örneği bitti',
            style: TextStyle(color: cs.onSurface.withOpacity(.6))),
      ],
    );
  }
}
