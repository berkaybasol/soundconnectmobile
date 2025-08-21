import 'package:flutter/material.dart';

class BackstageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackstageAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black.withOpacity(.14),
      toolbarHeight: 64,
      titleSpacing: 12,
      title: Row(
        children: [
          const SizedBox(width: 4),
          // Ortada arama
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                cursorColor: const Color(0xFFF48371),
                decoration: InputDecoration(
                  hintText: 'Ara: kullanıcı, etkinlik, parça…',
                  prefixIcon: Icon(Icons.search, color: cs.onSurface.withOpacity(.75)),
                  filled: true,
                  fillColor: cs.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF48371), width: 1.8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sağ aksiyonlar: İkinci El + Bildirim + Logo Menüsü
          IconButton(
            tooltip: 'İkinci El Satış',
            icon: Icon(Icons.gavel_outlined, color: cs.onSurface, size: 22),
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('İkinci El Satış (TODO)'))),
          ),
          IconButton(
            tooltip: 'Bildirimler',
            icon: Icon(Icons.notifications_none_rounded, color: cs.onSurface),
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Bildirimler (TODO)'))),
          ),
          _LogoMenu(popupColor: cs.surface, iconColor: cs.onSurface),
        ],
      ),
      flexibleSpace: const _SoftEdgeFade(height: 12, down: true),
    );
  }
}

class _LogoMenu extends StatelessWidget {
  final Color popupColor;
  final Color iconColor;
  const _LogoMenu({required this.popupColor, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Menü',
      position: PopupMenuPosition.under,
      itemBuilder: (ctx) => [
        _item(1, Icons.person_outline, 'Profilim'),
        _item(2, Icons.settings_outlined, 'Ayarlar'),
        _item(3, Icons.help_outline_rounded, 'Yardım'),
        _item(4, Icons.logout_rounded, 'Çıkış'),
      ],
      onSelected: (v) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Seçildi: $v (TODO)'))),
      child: Image.asset(
        'assets/images/sadece_amblem.png',
        width: 28, height: 28, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(Icons.music_note, color: iconColor),
      ),
    );
  }

  PopupMenuItem<int> _item(int v, IconData i, String t) =>
      PopupMenuItem<int>(value: v, child: Row(children: [
        Icon(i), const SizedBox(width: 10), Text(t),
      ]));
}

class _SoftEdgeFade extends StatelessWidget {
  final double height;
  final bool down;
  const _SoftEdgeFade({required this.height, this.down = true});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final colors = down
        ? [base.withOpacity(.90), base.withOpacity(0)]
        : [base.withOpacity(0), base.withOpacity(.90)];
    return IgnorePointer(
      child: Align(
        alignment: down ? Alignment.bottomCenter : Alignment.topCenter,
        child: SizedBox(
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors),
            ),
          ),
        ),
      ),
    );
  }
}
