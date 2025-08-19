// lib/features/onboarding/musician_onboarding_page.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// senin mevcut global dio provider'ını kullanıyoruz
import 'package:soundconnectmobile/core/network/dio_client.dart';

import 'package:soundconnectmobile/features/home/home_shell.dart';

// senin mevcut controller dosyan (daha önce attığın)
import 'package:soundconnectmobile/features/onboarding/musician_onboarding_controller.dart';

/// ---------------- DTO ----------------
class Instrument {
  final String id;
  final String name;
  Instrument({required this.id, required this.name});

  factory Instrument.fromJson(Map<String, dynamic> json) =>
      Instrument(id: json['id'].toString(), name: (json['name'] ?? '').toString());
}

/// ---------------- Repository ----------------
class InstrumentRepository {
  final Dio _dio;
  InstrumentRepository(this._dio);

  Future<List<Instrument>> getAll() async {
    final res = await _dio.get('/api/v1/user/instruments');
    if ((res.statusCode ?? 0) != 200 || res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Enstrüman listesi alınamadı',
      );
    }
    final list = (res.data['data'] as List?) ?? const [];
    return list
        .map((e) => Instrument.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

/// ---------------- Providers ----------------
final instrumentRepositoryProvider = Provider<InstrumentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return InstrumentRepository(dio);
});

final instrumentListProvider = FutureProvider<List<Instrument>>((ref) async {
  final repo = ref.watch(instrumentRepositoryProvider);
  return repo.getAll();
});

/// ---------------- Page ----------------
/// Onboarding: SADE—sadece sahne adı + enstrüman seçimi
class MusicianOnboardingPage extends ConsumerStatefulWidget {
  const MusicianOnboardingPage({super.key});

  @override
  ConsumerState<MusicianOnboardingPage> createState() =>
      _MusicianOnboardingPageState();
}

class _MusicianOnboardingPageState extends ConsumerState<MusicianOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _stageName = TextEditingController();
  final Set<String> _selectedInstrumentIds = {};

  @override
  void dispose() {
    _stageName.dispose();
    super.dispose();
  }

  Future<void> _openInstrumentPicker({
    required List<Instrument> instruments,
  }) async {
    final cs = Theme.of(context).colorScheme;

    // geçici state (bottom sheet kapatılınca asıla yazacağız)
    final Set<String> temp = {..._selectedInstrumentIds};
    String query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = instruments
                .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text('Enstrüman Seç', style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 12),

                  // arama
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Ara: gitar, piyano...',
                    ),
                    onChanged: (v) => setSheetState(() => query = v),
                  ),
                  const SizedBox(height: 10),

                  // seçili chipler
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: -6,
                      children: [
                        for (final id in temp)
                          _InstrumentChip(
                            label: instruments.firstWhere((x) => x.id == id).name,
                            onDeleted: () => setSheetState(() => temp.remove(id)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // liste
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: filtered.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('Sonuç yok', style: Theme.of(ctx).textTheme.bodyMedium),
                      )
                          : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          final selected = temp.contains(item.id);
                          return ListTile(
                            dense: true,
                            title: Text(item.name),
                            leading: Checkbox(
                              value: selected,
                              onChanged: (_) => setSheetState(() {
                                if (selected) temp.remove(item.id);
                                else temp.add(item.id);
                              }),
                            ),
                            onTap: () => setSheetState(() {
                              if (selected) temp.remove(item.id);
                              else temp.add(item.id);
                            }),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _selectedInstrumentIds
                                ..clear()
                                ..addAll(temp);
                            });
                            Navigator.pop(ctx);
                          },
                          child: Text('Tamam (${temp.length})'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final req = MusicianProfileSaveRequest(
      stageName: _stageName.text.trim(),
      instrumentIds: _selectedInstrumentIds.toList(),
      description: null,
      profilePicture: null,
      instagramUrl: null,
      youtubeUrl: null,
      soundcloudUrl: null,
      spotifyEmbedUrl: null,
    );

    await ref.read(musicianOnboardingControllerProvider.notifier).updateProfile(req);

    // <- ÖNEMLİ: await’ten sonra tekrar mounted kontrolü
    if (!mounted) return;

    final s = ref.read(musicianOnboardingControllerProvider);
    if (s.success) {
      // İsteğe bağlı: başarı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi 🎉')),
      );

      // <-- SADECE BU NAVİGASYON KALSIN (maybePop vs. yok)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeGate()),
            (route) => false,
      );
    } else if (s.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final listState = ref.watch(instrumentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Müzisyen Profilini Tamamla')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // SADE: sadece sahne adı
              TextFormField(
                controller: _stageName,
                decoration: const InputDecoration(
                  labelText: 'Sahne Adı',
                  prefixIcon: Icon(Icons.music_note),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Sahne adı zorunlu' : null,
              ),
              const SizedBox(height: 16),

              // Enstrüman seçimi (backend’den)
              listState.when(
                data: (instruments) {
                  return InkWell(
                    onTap: () => _openInstrumentPicker(instruments: instruments),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      isFocused: false,
                      isEmpty: _selectedInstrumentIds.isEmpty,
                      decoration: InputDecoration(
                        labelText: 'Enstrümanlar',
                        hintText: 'Seçiniz', // ← placeholder artık burada
                        prefixIcon: const Icon(Icons.piano),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        // odak rengi temanın primary’si (pembe) olacak şekilde:
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      // BOŞKEN child=null (hint görünsün, overlap olmasın)
                      child: _selectedInstrumentIds.isEmpty
                          ? null
                          : Wrap(
                        spacing: 6,
                        runSpacing: -6,
                        children: _selectedInstrumentIds.map((id) {
                          final name = instruments.firstWhere((x) => x.id == id).name;
                          return _InstrumentChip(
                            label: name,
                            onDeleted: () => setState(() {
                              _selectedInstrumentIds.remove(id);
                            }),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
                error: (e, _) => Text('Enstrümanlar yüklenemedi: $e'),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _onSave,
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstrumentChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;
  const _InstrumentChip({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
