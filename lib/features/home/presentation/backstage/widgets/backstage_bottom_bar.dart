import 'package:flutter/material.dart';

class BackstageBottomBar extends StatelessWidget {
  const BackstageBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BottomAppBar(
      color: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        height: 66,
        child: Stack(
          children: [
            const Positioned(
              top: 0, left: 0, right: 0, height: 12,
              child: _SoftEdgeFade(height: 12, down: true),
            ),
            Row(
              children: const [
                _BottomIconButton(
                  icon: Icons.post_add_rounded, label: 'İlan', toast: 'İlan (TODO)',
                ),
                Expanded(child: Center(child: _MainStageAnchorButton())),
                _BottomIconButton(
                  icon: Icons.chat_bubble_outline_rounded, label: 'Mesajlar', toast: 'Mesajlar (TODO)',
                ),
                _BottomIconButton(
                  icon: Icons.person_outline_rounded, label: 'Profil', toast: 'Profil (TODO)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MainStageAnchorButton extends StatelessWidget {
  const _MainStageAnchorButton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<int>(
      tooltip: 'MainStage',
      position: PopupMenuPosition.over,
      offset: const Offset(0, -220),
      itemBuilder: (ctx) => const [
        PopupMenuItem(value: 1, child: _MenuItem(icon: Icons.psychology_alt_outlined, title: 'Overthinking')),
        PopupMenuItem(value: 2, child: _MenuItem(icon: Icons.local_fire_department_outlined, title: 'Trending Sets')),
        PopupMenuItem(value: 3, child: _MenuItem(icon: Icons.location_city_outlined, title: 'City Vibes')),
      ],
      onSelected: (v) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Seçildi: $v (TODO)'))),
      child: SizedBox(
        width: 92, height: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch_outlined, color: cs.onSurface),
            const SizedBox(height: 4),
            Text('Git', style: TextStyle(color: cs.onSurface.withOpacity(.7), fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String title;
  const _MenuItem({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(icon, color: cs.onSurface), const SizedBox(width: 10),
      Text(title, style: TextStyle(color: cs.onSurface)),
    ]);
  }
}

class _BottomIconButton extends StatelessWidget {
  final IconData icon; final String label; final String toast;
  const _BottomIconButton({required this.icon, required this.label, required this.toast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toast))),
      splashColor: cs.onSurface.withOpacity(.08),
      highlightColor: cs.onSurface.withOpacity(.06),
      child: SizedBox(
        width: 92, height: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.onSurface),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: cs.onSurface.withOpacity(.7), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SoftEdgeFade extends StatelessWidget {
  final double height; final bool down;
  const _SoftEdgeFade({required this.height, this.down = true});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.black : Colors.white;
    final colors = down
        ? [base.withOpacity(.90), base.withOpacity(0)]
        : [base.withOpacity(0), base.withOpacity(.90)];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors),
      ),
    );
  }
}
