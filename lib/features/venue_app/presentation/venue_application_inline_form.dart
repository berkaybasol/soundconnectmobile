// lib/features/venue_app/presentation/venue_application_inline_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/features/venue_app/presentation/venue_application_controller.dart';

class VenueApplicationInlineForm extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  const VenueApplicationInlineForm({super.key, this.onSuccess});

  @override
  ConsumerState<VenueApplicationInlineForm> createState() => _VenueApplicationInlineFormState();
}

class _VenueApplicationInlineFormState extends ConsumerState<VenueApplicationInlineForm> {
  final _formKey = GlobalKey<FormState>();
  final _venueName = TextEditingController();
  final _venueAddress = TextEditingController();
  final _cityId = TextEditingController();
  final _districtId = TextEditingController();
  final _neighborhoodId = TextEditingController();

  @override
  void dispose() {
    _venueName.dispose();
    _venueAddress.dispose();
    _cityId.dispose();
    _districtId.dispose();
    _neighborhoodId.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref.read(venueApplicationControllerProvider.notifier).submit(
      venueName: _venueName.text.trim(),
      venueAddress: _venueAddress.text.trim(),
      cityId: _cityId.text.trim(),
      districtId: _districtId.text.trim(),
      neighborhoodId: _neighborhoodId.text.trim().isEmpty ? null : _neighborhoodId.text.trim(),
    );

    if (!mounted) return;
    final state = ref.read(venueApplicationControllerProvider);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başvurun alındı. İncelemeye gönderildi.')),
      );
      widget.onSuccess?.call();
    } else if (state.hasError) {
      final msg = state.error?.toString() ?? 'Başvuru gönderilemedi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(venueApplicationControllerProvider);
    final loading = async.isLoading;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: cs.outlineVariant),
    );
    final focused = border.copyWith(
      borderSide: BorderSide(color: cs.primary, width: 2),
    );

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Mekan Başvurusu', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Rol olarak “Mekan Sahibi” seçtiğiniz için başvuru formu gerekli.',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(.7)),
              ),
              const SizedBox(height: 12),

              // Venue Name
              TextFormField(
                controller: _venueName,
                enabled: !loading,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Mekan adı',
                  prefixIcon: const Icon(Icons.store_mall_directory_outlined),
                  filled: true, fillColor: Colors.white,
                  border: border, enabledBorder: border, focusedBorder: focused,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // Venue Address
              TextFormField(
                controller: _venueAddress,
                enabled: !loading,
                textInputAction: TextInputAction.next,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Adres',
                  prefixIcon: const Icon(Icons.place_outlined),
                  filled: true, fillColor: Colors.white,
                  border: border, enabledBorder: border, focusedBorder: focused,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // City UUID
              TextFormField(
                controller: _cityId,
                enabled: !loading,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9\-]'))],
                decoration: InputDecoration(
                  labelText: 'City ID (UUID)',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  filled: true, fillColor: Colors.white,
                  border: border, enabledBorder: border, focusedBorder: focused,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // District UUID
              TextFormField(
                controller: _districtId,
                enabled: !loading,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9\-]'))],
                decoration: InputDecoration(
                  labelText: 'District ID (UUID)',
                  prefixIcon: const Icon(Icons.map_outlined),
                  filled: true, fillColor: Colors.white,
                  border: border, enabledBorder: border, focusedBorder: focused,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // Neighborhood UUID (optional)
              TextFormField(
                controller: _neighborhoodId,
                enabled: !loading,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9\-]'))],
                decoration: InputDecoration(
                  labelText: 'Neighborhood ID (UUID) — opsiyonel',
                  prefixIcon: const Icon(Icons.apartment_outlined),
                  filled: true, fillColor: Colors.white,
                  border: border, enabledBorder: border, focusedBorder: focused,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                height: 46,
                child: FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Başvuruyu Gönder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
