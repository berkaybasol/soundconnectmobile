import 'package:flutter/material.dart';

class MainStageBottomBar extends StatelessWidget {
  const MainStageBottomBar({super.key});

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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomIconButton(
                  icon: Icons.chat_bubble_outline_rounded, label: 'Mesajlar', toast: 'Mesajlar (TODO)',
                ),
                _BottomIconButton(
                  icon: Icons.notifications_none_rounded, label: 'Bildirim', toast: 'Bildirim (TODO)',
                ),
                _BottomIconButton(
                  icon: Icons.person_outline_rounded, label: 'Profil', toast: 'Profil (TODO)',
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Image.asset(
                    'assets/images/sadece_amblem.png',
                    width: 28, height: 28, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(Icons.music_note, color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
