// lib/features/auth/presentation/register_page.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'register_controller.dart';
import 'verify_code_page.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';

// ORTAK MODEL İMPORTU (lokal sınıf kaldırıldı) -> eklendi
import 'models/venue_application_draft.dart';

/// Küçük yardımcı tipler
class _IdName {
  final String id;
  final String name;
  const _IdName(this.id, this.name);

  factory _IdName.fromJson(Map<String, dynamic> j) =>
      _IdName(j['id'].toString(), (j['name'] ?? '').toString());
}

// (DİKKAT) Buradaki lokal VenueApplicationDraft sınıfı kaldırıldı.
// Artık models/venue_application_draft.dart dosyasından geliyor.

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _rePassword = TextEditingController();

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _rePasswordFocus = FocusNode();

  bool _obscure = true;
  bool _obscure2 = true;

  // USER kaldırıldı
  static const _roles = <String, String>{
    'ROLE_MUSICIAN': 'Müzisyen',
    'ROLE_VENUE': 'Mekan Sahibi',
    'ROLE_LISTENER': 'Dinleyici',
    'ROLE_STUDIO': 'Stüdyo',
    'ROLE_ORGANIZER': 'Organizatör',
    'ROLE_PRODUCER': 'Prodüktör',
  };

  // Başlangıçta seçim yok → hint görünsün
  String? _selectedRole;

  // ==== ROLE_VENUE alanları ====
  final _venueName = TextEditingController();
  final _venueAddress = TextEditingController();

  String? _selectedCityId;
  String? _selectedDistrictId;
  String? _selectedNeighborhoodId;

  List<_IdName> _cities = [];
  List<_IdName> _districts = [];
  List<_IdName> _neighborhoods = [];

  bool _loadingCities = false;
  bool _loadingDistricts = false;
  bool _loadingNeighborhoods = false;

  String? _locError; // tek satır uyarı basmak için

  Dio get _dio => ref.read(dioProvider);

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _rePassword.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _rePasswordFocus.dispose();

    _venueName.dispose();
    _venueAddress.dispose();
    super.dispose();
  }

  Future<void> _ensureCitiesLoaded() async {
    if (_cities.isNotEmpty || _loadingCities) return;
    await _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() {
      _loadingCities = true;
      _locError = null;
    });
    try {
      final res = await _dio.get('/api/v1/cities/get-all-cities');
      final body = res.data as Map?;
      final list = (body?['data'] as List?) ?? const [];
      _cities = list
          .map((e) => _IdName.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _locError = 'Şehirler yüklenemedi';
    } finally {
      _loadingCities = false;
      setState(() {});
    }
  }

  Future<void> _loadDistricts(String cityId) async {
    setState(() {
      _loadingDistricts = true;
      _locError = null;
      _districts = [];
      _neighborhoods = [];
      _selectedDistrictId = null;
      _selectedNeighborhoodId = null;
    });
    try {
      final res = await _dio.get('/api/v1/districts/get-by-city/$cityId');
      final status = res.statusCode ?? 0;

      // Beklenen BaseResponse değilse ya da 200 değilse fallback'e geç
      if (status != 200 || res.data is! Map || (res.data['success'] != true)) {
        // Fallback: tüm ilçeleri çek -> cityId ile filtrele
        final all = await _dio.get('/api/v1/districts/get-all-districts');
        final body = (all.data is Map) ? all.data as Map : {};
        final list = (body['data'] is List) ? body['data'] as List : const [];
        _districts = list
            .where((e) => (e is Map) && e['cityId']?.toString() == cityId)
            .map<_IdName>((e) => _IdName.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      } else {
        final body = res.data as Map;
        final list = (body['data'] is List) ? body['data'] as List : const [];
        _districts = list
            .map<_IdName>((e) => _IdName.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      }

      if (_districts.isEmpty) {
        // veri yoksa hata yerine boş liste bırakıp sessiz geçiyoruz
        debugPrint('[Register] İlçe listesi boş geldi (cityId=$cityId)');
      }
    } catch (e, st) {
      _locError = 'İlçeler yüklenemedi';
      debugPrint('[Register] _loadDistricts error: $e\n$st');
    } finally {
      _loadingDistricts = false;
      setState(() {});
    }
  }

  Future<void> _loadNeighborhoods(String districtId) async {
    setState(() {
      _loadingNeighborhoods = true;
      _locError = null;
      _neighborhoods = [];
      _selectedNeighborhoodId = null;
    });
    try {
      final res = await _dio.get('/api/v1/neighborhoods/get-by-district/$districtId');
      final status = res.statusCode ?? 0;

      if (status != 200 || res.data is! Map || (res.data['success'] != true)) {
        // Fallback: tüm mahalleleri çek -> districtId ile filtrele
        final all = await _dio.get('/api/v1/neighborhoods/get-all');
        final body = (all.data is Map) ? all.data as Map : {};
        final list = (body['data'] is List) ? body['data'] as List : const [];
        _neighborhoods = list
            .where((e) => (e is Map) && e['districtId']?.toString() == districtId)
            .map<_IdName>((e) => _IdName.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      } else {
        final body = res.data as Map;
        final list = (body['data'] is List) ? body['data'] as List : const [];
        _neighborhoods = list
            .map<_IdName>((e) => _IdName.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      }
    } catch (e, st) {
      _locError = 'Mahalleler yüklenemedi';
      debugPrint('[Register] _loadNeighborhoods error: $e\n$st');
    } finally {
      _loadingNeighborhoods = false;
      setState(() {});
    }
  }

  VenueApplicationDraft? _buildVenueDraftIfNeeded() {
    if (_selectedRole != 'ROLE_VENUE') return null;

    final name = _venueName.text.trim();
    final address = _venueAddress.text.trim();

    if (name.isEmpty ||
        address.isEmpty ||
        _selectedCityId == null ||
        _selectedDistrictId == null) {
      _locError = 'Mekan adı, adres, şehir ve ilçe zorunludur';
      setState(() {});
      return null;
    }

    return VenueApplicationDraft(
      venueName: name,
      venueAddress: address,
      cityId: _selectedCityId!,
      districtId: _selectedDistrictId!,
      neighborhoodId: _selectedNeighborhoodId,
    );
  }

  Future<void> _onRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final role = _selectedRole;
    if (role == null) return; // validator uyarıyor

    // ROLE_VENUE ise taslak hazırlar, eksikse dururuz
    final draft = _buildVenueDraftIfNeeded();
    if (role == 'ROLE_VENUE' && draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen mekan bilgilerini tamamlayın')),
      );
      return;
    }

    final notifier = ref.read(registerControllerProvider.notifier);
    notifier.clearError();

    final outcome = await notifier.register(
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      rePassword: _rePassword.text,
      role: role,
    );

    if (!mounted) return;
    final s = ref.read(registerControllerProvider);

    if (outcome != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt alındı. Doğrulama kodunu gir.')),
      );
      // VerifyCodePage’e VenueApplication taslağını ve login için kimlik bilgilerini geçiyoruz.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyCodePage(
            email: outcome.email,
            initialOtpTtlSeconds: outcome.otpTtlSeconds,
            // ↓↓↓ ROLE_VENUE ise doldurulmuş taslak ve login bilgileri
            venueDraft: draft,
            usernameForAutoLogin: _username.text.trim(),
            passwordForAutoLogin: _password.text,
          ),
        ),
      );
    } else if (s.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.error!)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cs.outlineVariant),
    );
    final fieldFocused = fieldBorder.copyWith(
      borderSide: BorderSide(color: cs.primary, width: 2),
    );

    final header = Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Image.asset(
            'assets/images/sadece_amblem.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );

    final roleDropdown = DropdownButtonFormField<String>(
      value: _selectedRole,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Rol',
        prefixIcon: const Icon(Icons.badge_outlined),
        filled: true,
        fillColor: Colors.white,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldFocused,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      hint: const Text('Sizi nasıl tanıyalım?'),
      items: _roles.entries
          .map((e) =>
          DropdownMenuItem<String>(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: state.loading
          ? null
          : (v) async {
        setState(() => _selectedRole = v);
        // Mekan ise şehirleri bir defa çek
        if (v == 'ROLE_VENUE') {
          await _ensureCitiesLoaded();
        }
      },
      validator: (v) => v == null ? 'Bir rol seçin' : null,
    );

    final venuePanel = (_selectedRole == 'ROLE_VENUE')
        ? _VenueForm(
      theme: theme,
      cs: cs,
      fieldBorder: fieldBorder,
      fieldFocused: fieldFocused,
      venueName: _venueName,
      venueAddress: _venueAddress,
      cities: _cities,
      districts: _districts,
      neighborhoods: _neighborhoods,
      selectedCityId: _selectedCityId,
      selectedDistrictId: _selectedDistrictId,
      selectedNeighborhoodId: _selectedNeighborhoodId,
      loadingCities: _loadingCities,
      loadingDistricts: _loadingDistricts,
      loadingNeighborhoods: _loadingNeighborhoods,
      locError: _locError,
      onSelectCity: (id) async {
        setState(() => _selectedCityId = id);
        if (id != null) {
          await _loadDistricts(id);
        } else {
          setState(() {
            _districts = [];
            _neighborhoods = [];
            _selectedDistrictId = null;
            _selectedNeighborhoodId = null;
          });
        }
      },
      onSelectDistrict: (id) async {
        setState(() => _selectedDistrictId = id);
        if (id != null) {
          await _loadNeighborhoods(id);
        } else {
          setState(() {
            _neighborhoods = [];
            _selectedNeighborhoodId = null;
          });
        }
      },
      onSelectNeighborhood: (id) =>
          setState(() => _selectedNeighborhoodId = id),
    )
        : const SizedBox.shrink();

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // USERNAME
          TextFormField(
            controller: _username,
            focusNode: _usernameFocus,
            enabled: !state.loading,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: 'Kullanıcı adı',
              hintText: 'kullanici_adi',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_emailFocus),
          ),
          const SizedBox(height: 12),

          // EMAIL
          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            enabled: !state.loading,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'E-posta',
              hintText: 'ornek@mail.com',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Zorunlu';
              final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
              if (!emailRegex.hasMatch(v.trim())) {
                return 'Geçerli bir e-posta girin';
              }
              return null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_passwordFocus),
          ),
          const SizedBox(height: 12),

          // PASSWORD
          TextFormField(
            controller: _password,
            focusNode: _passwordFocus,
            enabled: !state.loading,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Şifre',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
                onPressed:
                state.loading ? null : () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_rePasswordFocus),
          ),
          const SizedBox(height: 12),

          // REPASSWORD
          TextFormField(
            controller: _rePassword,
            focusNode: _rePasswordFocus,
            enabled: !state.loading,
            obscureText: _obscure2,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Şifre (tekrar)',
              prefixIcon: const Icon(Icons.lock_reset_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure2 ? 'Şifreyi göster' : 'Şifreyi gizle',
                onPressed:
                state.loading ? null : () => setState(() => _obscure2 = !_obscure2),
                icon: Icon(
                  _obscure2 ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Zorunlu';
              if (v != _password.text) return 'Şifreler uyuşmuyor';
              return null;
            },
            onFieldSubmitted: (_) => _onRegister(),
          ),
          const SizedBox(height: 12),

          // ROLE
          roleDropdown,

          // VENUE FORM
          const SizedBox(height: 12),
          venuePanel,

          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: state.loading ? null : _onRegister,
              child: state.loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Üye ol'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              form,
            ],
          ),
        ),
      ),
    );

    final footer = SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hesabın var mı?",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withOpacity(.75),
              ),
            ),
            TextButton(
              onPressed: state.loading ? null : () => Navigator.of(context).maybePop(),
              child: Text(
                'Giriş Yap',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: card,
        ),
      ),
      bottomNavigationBar: footer,
    );
  }
}

/// Yalnızca ROLE_VENUE seçilince görünen form bloğu
class _VenueForm extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  final OutlineInputBorder fieldBorder;
  final OutlineInputBorder fieldFocused;

  final TextEditingController venueName;
  final TextEditingController venueAddress;

  final List<_IdName> cities;
  final List<_IdName> districts;
  final List<_IdName> neighborhoods;

  final String? selectedCityId;
  final String? selectedDistrictId;
  final String? selectedNeighborhoodId;

  final bool loadingCities;
  final bool loadingDistricts;
  final bool loadingNeighborhoods;

  final String? locError;

  final ValueChanged<String?> onSelectCity;
  final ValueChanged<String?> onSelectDistrict;
  final ValueChanged<String?> onSelectNeighborhood;

  const _VenueForm({
    required this.theme,
    required this.cs,
    required this.fieldBorder,
    required this.fieldFocused,
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
    required this.locError,
    required this.onSelectCity,
    required this.onSelectDistrict,
    required this.onSelectNeighborhood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mekan Başvurusu',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 12),

          // Mekan Adı
          TextFormField(
            controller: venueName,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Mekan adı',
              prefixIcon: const Icon(Icons.storefront_outlined),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Mekan adı zorunludur';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Adres
          TextFormField(
            controller: venueAddress,
            textInputAction: TextInputAction.next,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Adres',
              prefixIcon: const Icon(Icons.location_on_outlined),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Adres zorunludur';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Şehir
          DropdownButtonFormField<String>(
            value: selectedCityId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Şehir',
              prefixIcon: const Icon(Icons.location_city_outlined),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            hint:
            loadingCities ? const Text('Yükleniyor...') : const Text('Şehir seçin'),
            items: cities
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: loadingCities ? null : onSelectCity,
            validator: (v) => v == null ? 'Şehir seçin' : null,
          ),
          const SizedBox(height: 10),

          // İlçe
          DropdownButtonFormField<String>(
            value: selectedDistrictId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'İlçe',
              prefixIcon: const Icon(Icons.map_outlined),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
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

          // Mahalle (opsiyonel)
          DropdownButtonFormField<String>(
            value: selectedNeighborhoodId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Mahalle (opsiyonel)',
              prefixIcon: const Icon(Icons.place_outlined),
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldFocused,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
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

          if (locError != null) ...[
            const SizedBox(height: 8),
            Text(
              locError!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.error, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
