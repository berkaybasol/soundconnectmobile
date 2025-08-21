// lib/features/profile/presentation/widgets/venues_marquee.dart
import 'dart:async';
import 'dart:ui';
import 'package:characters/characters.dart';
import 'package:flutter/material.dart';

class VenuesMarquee extends StatefulWidget {
  final List<String>? venues; // null veya boşsa fallback gösterir
  const VenuesMarquee({super.key, this.venues});

  @override
  State<VenuesMarquee> createState() => _VenuesMarqueeState();
}

class _VenuesMarqueeState extends State<VenuesMarquee> {
  final _controller = ScrollController();
  Timer? _timer;
  double _offset = 0;

  List<String> get _venues =>
      (widget.venues == null || widget.venues!.isEmpty)
          ? const ['Henüz eklenmemiş']
          : widget.venues!;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
        if (!_controller.hasClients) return;
        final max = _controller.position.maxScrollExtent;
        if (max <= 0) return;
        _offset = (_offset + 1.0);
        if (_offset >= max) _offset = 0;
        _controller.jumpTo(_offset);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _venues;
    final doubled = [...items, ...items];

    final borderColor =
        Color.lerp(cs.primary, cs.tertiary, .5) ?? cs.outlineVariant;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          height: double.infinity, // parent belirler (örn: SizedBox(height: 44))
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(.72),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withOpacity(.35)),
            boxShadow: [
              BoxShadow(
                color: cs.tertiary.withOpacity(.12),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            itemCount: doubled.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _VenueChip(name: doubled[i]),
          ),
        ),
      ),
    );
  }
}

class _VenueChip extends StatelessWidget {
  final String name;
  const _VenueChip({required this.name});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initial = (name.isNotEmpty) ? name.characters.first.toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
        color: cs.surface.withOpacity(.95),
        boxShadow: [
          BoxShadow(color: cs.primary.withOpacity(.08), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: cs.primary.withOpacity(.15),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withOpacity(.85),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withOpacity(.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
