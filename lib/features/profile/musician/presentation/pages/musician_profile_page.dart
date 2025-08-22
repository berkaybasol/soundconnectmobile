import 'package:flutter/material.dart';

class MusicianProfilePage extends StatefulWidget {
  const MusicianProfilePage({super.key});

  @override
  State<MusicianProfilePage> createState() => _MusicianProfilePageState();
}

class _MusicianProfilePageState extends State<MusicianProfilePage> {
  // ----- FORM -----
  final _formKey = GlobalKey<FormState>();

  // Başlangıç değerleri (dummy) — backend’den doldurulacak
  final TextEditingController _stageNameCtrl =
  TextEditingController(text: "Buğra Şahin (BRLN)");
  final TextEditingController _bandNameCtrl =
  TextEditingController(text: "MEGER");
  final TextEditingController _bioCtrl = TextEditingController(text: "");
  final TextEditingController _spotifyUrlCtrl =
  TextEditingController(text: "https://open.spotify.com/artist/xxxxxx");
  final TextEditingController _instagramCtrl =
  TextEditingController(text: "https://instagram.com/brln");
  final TextEditingController _youtubeCtrl =
  TextEditingController(text: "");
  final TextEditingController _soundcloudCtrl =
  TextEditingController(text: "");

  bool _showSpotify = true; // TODO: backend'den oku/kaydet
  bool _hasBand = true;

  // Mekanlar
  final List<String> _venues = [
    "Babylon",
    "IF Performance",
    "Blind",
    "The Populist",
  ];
  final TextEditingController _newVenueCtrl = TextEditingController();

  // Profil resmi (dummy) — sadece placeholder; picker ekleme alanı
  ImageProvider? _avatarImage;

  @override
  void dispose() {
    _stageNameCtrl.dispose();
    _bandNameCtrl.dispose();
    _bioCtrl.dispose();
    _spotifyUrlCtrl.dispose();
    _instagramCtrl.dispose();
    _youtubeCtrl.dispose();
    _soundcloudCtrl.dispose();
    _newVenueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFEB6A5C),
        title: Text(
          "Profili Düzenle",
          style: text.titleLarge?.copyWith(color: const Color(0xFFEB6A5C)),
        ),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text(
              "Kaydet",
              style: TextStyle(
                color: Color(0xFFEB6A5C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ------- AVATAR -------
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFFE58AA0),
                        backgroundImage: _avatarImage,
                        child: _avatarImage == null
                            ? const Icon(Icons.person, color: Colors.white, size: 48)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _onChangeAvatar, // TODO: image picker
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text("Fotoğrafı Değiştir"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEB6A5C),
                          side: const BorderSide(color: Color(0xFFEB6A5C)),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ------- SAHNE ADI -------
                _LabeledField(
                  label: "Sahne Adı",
                  child: TextFormField(
                    controller: _stageNameCtrl,
                    decoration: const InputDecoration(
                      hintText: "Örn. Buğra Şahin (BRLN)",
                      border: OutlineInputBorder(),
                      filled: false
                    ),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Sahne adı zorunlu" : null,
                  ),
                ),

                const SizedBox(height: 12),

                // ------- GRUP / BAND -------
                SwitchListTile.adaptive(
                  title: const Text("Bir gruptayım"),
                  value: _hasBand,
                  onChanged: (v) => setState(() => _hasBand = v),
                  activeColor: const Color(0xFFEB6A5C),
                  contentPadding: EdgeInsets.zero,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _hasBand
                      ? Padding(
                    key: const ValueKey("bandField"),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _LabeledField(
                      label: "Grup Adı",
                      child: TextFormField(
                        controller: _bandNameCtrl,
                        decoration: const InputDecoration(
                          hintText: "Örn. MEGER",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (!_hasBand) return null;
                          if (v == null || v.trim().isEmpty) {
                            return "Grup adını yaz";
                          }
                          return null;
                        },
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 8),

                // ------- MEKANLAR -------
                _SectionHeader(title: "Aktif Çaldığın Mekanlar"),
                const SizedBox(height: 8),
                _VenuesEditor(
                  venues: _venues,
                  newVenueCtrl: _newVenueCtrl,
                  onAdd: _addVenue,
                  onRemove: _removeVenue,
                ),

                const SizedBox(height: 20),

                // ------- SPOTIFY -------
                _SectionHeader(
                  title: "Spotify",
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Göster",
                          style: text.titleMedium
                              ?.copyWith(color: const Color(0xFF49454F))),
                      const SizedBox(width: 8),
                      Switch(
                        value: _showSpotify,
                        activeColor: const Color(0xFFE58AA0),
                        onChanged: (v) => setState(() => _showSpotify = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _LabeledField(
                  label: "Spotify Sanatçı/Playlist URL (opsiyonel)",
                  child: TextFormField(
                    controller: _spotifyUrlCtrl,
                    decoration: const InputDecoration(
                      hintText: "https://open.spotify.com/...",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if ((v ?? "").trim().isEmpty) return null;
                      final ok = Uri.tryParse(v!.trim())?.hasAbsolutePath ?? false;
                      return ok ? null : "Geçerli bir URL gir";
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ------- BIO -------
                _SectionHeader(title: "Hakkımda"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText:
                    "Kısa biyografi, tarzın, sahne deneyimi, işbirliği aradığın alanlar...",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // ------- SOSYAL LİNKLER -------
                _SectionHeader(title: "Sosyal Bağlantılar"),
                const SizedBox(height: 8),
                _LabeledField(
                  label: "Instagram",
                  child: TextFormField(
                    controller: _instagramCtrl,
                    decoration: const InputDecoration(
                      hintText: "https://instagram.com/...",
                      border: OutlineInputBorder(),
                    ),
                    validator: _optUrlValidator,
                  ),
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: "YouTube",
                  child: TextFormField(
                    controller: _youtubeCtrl,
                    decoration: const InputDecoration(
                      hintText: "https://youtube.com/@...",
                      border: OutlineInputBorder(),
                    ),
                    validator: _optUrlValidator,
                  ),
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: "SoundCloud",
                  child: TextFormField(
                    controller: _soundcloudCtrl,
                    decoration: const InputDecoration(
                      hintText: "https://soundcloud.com/...",
                      border: OutlineInputBorder(),
                    ),
                    validator: _optUrlValidator,
                  ),
                ),

                const SizedBox(height: 28),

                // ------- ALT BUTONLAR -------
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEB6A5C),
                          side: const BorderSide(color: Color(0xFFEB6A5C)),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("İptal"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEB6A5C),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text("Kaydet"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Actions ----------
  void _onChangeAvatar() {
    // TODO: Image picker ile resmi seç → setState(() => _avatarImage = FileImage(...));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fotoğraf seçme TODO")),
    );
  }

  void _addVenue() {
    final v = _newVenueCtrl.text.trim();
    if (v.isEmpty) return;
    if (_venues.contains(v)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bu mekan zaten listede")),
      );
      return;
    }
    setState(() {
      _venues.add(v);
      _newVenueCtrl.clear();
    });
  }

  void _removeVenue(String v) {
    setState(() => _venues.remove(v));
  }

  String? _optUrlValidator(String? v) {
    if ((v ?? "").trim().isEmpty) return null;
    final ok = Uri.tryParse(v!.trim())?.hasAbsolutePath ?? false;
    return ok ? null : "URL biçimi hatalı";
  }

  void _onCancel() {
    // go_router kullanıyorsan context.pop() çalışır, değilse Navigator.pop().
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    // ---- KAYDETME PAYLOAD ----
    final payload = {
      "stageName": _stageNameCtrl.text.trim(),
      "hasBand": _hasBand,
      "bandName": _hasBand ? _bandNameCtrl.text.trim() : null,
      "bio": _bioCtrl.text.trim(),
      "showSpotify": _showSpotify,
      "spotifyUrl": _spotifyUrlCtrl.text.trim().isEmpty ? null : _spotifyUrlCtrl.text.trim(),
      "instagram": _instagramCtrl.text.trim().isEmpty ? null : _instagramCtrl.text.trim(),
      "youtube": _youtubeCtrl.text.trim().isEmpty ? null : _youtubeCtrl.text.trim(),
      "soundcloud": _soundcloudCtrl.text.trim().isEmpty ? null : _soundcloudCtrl.text.trim(),
      "venues": _venues,
      // "avatarFile": ... // seçtiğin dosyayı burada ekleyeceksin
    };

    // TODO: backend'e gönder (repo/bloc/service)
    // await profileRepo.update(payload);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil kaydedildi (dummy)")),
    );

    // Kaydet sonrası geri dön
    if (Navigator.canPop(context)) {
      Navigator.pop(context, payload); // istersen payload döndür
    }
  }
}

/* ----------------- yardımcı widgetlar ----------------- */

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: text.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF49454F),
            )),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _VenuesEditor extends StatelessWidget {
  final List<String> venues;
  final TextEditingController newVenueCtrl;
  final VoidCallback onAdd;
  final void Function(String) onRemove;

  const _VenuesEditor({
    required this.venues,
    required this.newVenueCtrl,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE6D8E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: -6,
              children: venues
                  .map((v) => Chip(
                label: Text(v),
                backgroundColor: const Color(0xFFF7F0EE),
                labelStyle: const TextStyle(
                  color: Color(0xFFEB6A5C),
                  fontWeight: FontWeight.w600,
                ),
                deleteIcon: const Icon(Icons.close, size: 18, color: Color(0xFFEB6A5C)),
                onDeleted: () => onRemove(v),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFE6D8E0)),
                ),
              ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: newVenueCtrl,
                decoration: const InputDecoration(
                  hintText: "Yeni mekan ekle",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text("Ekle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEB6A5C),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
