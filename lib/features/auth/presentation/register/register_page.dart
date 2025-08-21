import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'register_controller.dart';
import '../verify/verify_code_page.dart';
import '../../../venue_app/data/models/requests/venue_application_draft.dart';

// Location
import 'package:soundconnectmobile/features/location/presentation/location_controller.dart';

// widgets
import 'widgets/register_header_logo.dart';
import 'widgets/username_email_fields.dart';
import 'widgets/password_fields.dart';
import 'widgets/role_dropdown.dart';
import 'widgets/venue_form.dart';
import 'widgets/register_footer.dart';

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

  static const _roles = <String, String>{
    'ROLE_MUSICIAN': 'Müzisyen',
    'ROLE_VENUE': 'Mekan Sahibi',
    'ROLE_LISTENER': 'Dinleyici',
    'ROLE_STUDIO': 'Stüdyo',
    'ROLE_ORGANIZER': 'Organizatör',
    'ROLE_PRODUCER': 'Prodüktör',
  };

  String? _selectedRole;

  // Venue alanları
  final _venueName = TextEditingController();
  final _venueAddress = TextEditingController();
  String? _selectedCityId;
  String? _selectedDistrictId;
  String? _selectedNeighborhoodId;

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

  VenueApplicationDraft? _buildVenueDraftIfNeeded() {
    if (_selectedRole != 'ROLE_VENUE') return null;
    final name = _venueName.text.trim();
    final address = _venueAddress.text.trim();
    if (name.isEmpty || address.isEmpty || _selectedCityId == null || _selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mekan adı, adres, şehir ve ilçe zorunludur')),
      );
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
    if (_selectedRole == null) return;

    final draft = _buildVenueDraftIfNeeded();
    if (_selectedRole == 'ROLE_VENUE' && draft == null) return;

    final notifier = ref.read(registerControllerProvider.notifier);
    notifier.clearError();

    final outcome = await notifier.register(
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      rePassword: _rePassword.text,
      role: _selectedRole!,
    );

    if (!mounted) return;
    final s = ref.read(registerControllerProvider);

    if (outcome != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt alındı. Doğrulama kodunu gir.')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyCodePage(
            email: outcome.email,
            initialOtpTtlSeconds: outcome.otpTtlSeconds,
            venueDraft: draft,
            usernameForAutoLogin: _username.text.trim(),
            passwordForAutoLogin: _password.text,
          ),
        ),
      );
    } else if (s.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.error!)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(locationControllerProvider);
    final reg = ref.watch(registerControllerProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const RegisterHeaderLogo(),

                      UsernameEmailFields(
                        username: _username,
                        email: _email,
                        usernameFocus: _usernameFocus,
                        emailFocus: _emailFocus,
                        onUsernameSubmitted: () => _emailFocus.requestFocus(),
                      ),
                      const SizedBox(height: 12),

                      PasswordFields(
                        password: _password,
                        rePassword: _rePassword,
                        passwordFocus: _passwordFocus,
                        rePasswordFocus: _rePasswordFocus,
                        obscure1: _obscure,
                        obscure2: _obscure2,
                        onToggle1: () => setState(() => _obscure = !_obscure),
                        onToggle2: () => setState(() => _obscure2 = !_obscure2),
                        onDone: _onRegister,
                      ),
                      const SizedBox(height: 12),

                      RoleDropdown(
                        roles: _roles,
                        value: _selectedRole,
                        onChanged: (v) async {
                          setState(() => _selectedRole = v);
                          if (v == 'ROLE_VENUE') {
                            await ref.read(locationControllerProvider.notifier).ensureCitiesLoaded();
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      if (_selectedRole == 'ROLE_VENUE')
                        VenueForm(
                          venueName: _venueName,
                          venueAddress: _venueAddress,
                          cities: loc.cities,
                          districts: loc.districts,
                          neighborhoods: loc.neighborhoods,
                          selectedCityId: _selectedCityId,
                          selectedDistrictId: _selectedDistrictId,
                          selectedNeighborhoodId: _selectedNeighborhoodId,
                          loadingCities: loc.loadingCities,
                          loadingDistricts: loc.loadingDistricts,
                          loadingNeighborhoods: loc.loadingNeighborhoods,
                          errorText: loc.errorMessage,
                          onSelectCity: (id) async {
                            setState(() {
                              _selectedCityId = id;
                              _selectedDistrictId = null;
                              _selectedNeighborhoodId = null;
                            });
                            if (id != null) {
                              await ref.read(locationControllerProvider.notifier).loadDistricts(id);
                            }
                          },
                          onSelectDistrict: (id) async {
                            setState(() {
                              _selectedDistrictId = id;
                              _selectedNeighborhoodId = null;
                            });
                            if (id != null) {
                              await ref
                                  .read(locationControllerProvider.notifier)
                                  .loadNeighborhoods(id);
                            }
                          },
                          onSelectNeighborhood: (id) =>
                              setState(() => _selectedNeighborhoodId = id),
                        ),

                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: reg.loading ? null : _onRegister,
                          child: reg.loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text('Üye ol'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: RegisterFooter(
        onGoLogin: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
