import 'package:flutter/material.dart';
import 'package:soundconnectmobile/features/auth/presentation/login/widgets/auth_styles.dart';
import 'package:soundconnectmobile/features/location/data/models/id_name.dart';

class VenueForm extends StatelessWidget {
  final TextEditingController venueName;
  final TextEditingController venueAddress;

  final List<IdName> cities;
  final List<IdName> districts;
  final List<IdName> neighborhoods;

  final String? selectedCityId;
  final String? selectedDistrictId;
  final String? selectedNeighborhoodId;

  final bool loadingCities;
  final bool loadingDistricts;
  final bool loadingNeighborhoods;

  final String? errorText;

  final ValueChanged<String?> onSelectCity;
  final ValueChanged<String?> onSelectDistrict;
  final ValueChanged<String?> onSelectNeighborhood;

  const VenueForm({
    super.key,
    required this.venueName,
    required this.venueAddress,
    required this.cities,
    required this.districts,
    required this.neighborhoods,
    required this.selectedCityId,
    required this.selectedDistrictId,
    required this.selectedNeighborhoodId,
    required this.loadingCities,
    required this.loadingDistricts,
    required this.loadingNeighborhoods,
    required this.errorText,
    required this.onSelectCity,
    required this.onSelectDistrict,
    required this.onSelectNeighborhood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mekan Başvurusu',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: venueName,
            textInputAction: TextInputAction.next,
            decoration: AuthStyles.decoration(
              context: context,
              labelText: 'Mekan adı',
              prefixIcon: const Icon(Icons.storefront_outlined),
            ).copyWith(fillColor: Colors.transparent),
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Mekan adı zorunludur' : null,
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: venueAddress,
            maxLines: 2,
            textInputAction: TextInputAction.next,
            decoration: AuthStyles.decoration(
              context: context,
              labelText: 'Adres',
              prefixIcon: const Icon(Icons.location_on_outlined),
            ).copyWith(fillColor: Colors.transparent),
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Adres zorunludur' : null,
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: selectedCityId,
            isExpanded: true,
            decoration: AuthStyles.decoration(
              context: context,
              labelText: 'Şehir',
              prefixIcon: const Icon(Icons.location_city_outlined),
            ).copyWith(fillColor: Colors.transparent),
            hint: loadingCities
                ? const Text('Yükleniyor...')
                : const Text('Şehir seçin'),
            items: cities
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: loadingCities ? null : onSelectCity,
            validator: (v) => v == null ? 'Şehir seçin' : null,
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: selectedDistrictId,
            isExpanded: true,
            decoration: AuthStyles.decoration(
              context: context,
              labelText: 'İlçe',
              prefixIcon: const Icon(Icons.map_outlined),
            ).copyWith(fillColor: Colors.transparent),
            hint: (selectedCityId == null)
                ? const Text('Önce şehir seçin')
                : (loadingDistricts
                ? const Text('Yükleniyor...')
                : const Text('İlçe seçin')),
            items: districts
                .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                .toList(),
            onChanged:
            (selectedCityId == null || loadingDistricts) ? null : onSelectDistrict,
            validator: (v) => v == null ? 'İlçe seçin' : null,
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: selectedNeighborhoodId,
            isExpanded: true,
            decoration: AuthStyles.decoration(
              context: context,
              labelText: 'Mahalle (opsiyonel)',
              prefixIcon: const Icon(Icons.place_outlined),
            ).copyWith(fillColor: Colors.transparent),
            hint: (selectedDistrictId == null)
                ? const Text('Önce ilçe seçin')
                : (loadingNeighborhoods
                ? const Text('Yükleniyor...')
                : const Text('Mahalle (isteğe bağlı)')),
            items: neighborhoods
                .map((n) => DropdownMenuItem(value: n.id, child: Text(n.name)))
                .toList(),
            onChanged: (selectedDistrictId == null || loadingNeighborhoods)
                ? null
                : onSelectNeighborhood,
          ),

          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              errorText!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.error, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
