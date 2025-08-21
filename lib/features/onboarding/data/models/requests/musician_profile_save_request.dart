// lib/features/onboarding/data/models/requests/musician_profile_save_request.dart

/// Müzisyen onboarding profili için backend'e giden request DTO.
/// Boş alanlar gönderildiğinde backend tarafında genelde null kabul edilir.
/// İhtiyaç oldukça alanları genişletebilirsin.
class MusicianProfileSaveRequest {
  final String? stageName;
  final String? description;
  final String? profilePicture; // base64, url veya storage key
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? soundcloudUrl;
  final String? spotifyEmbedUrl;
  final List<String> instrumentIds;

  const MusicianProfileSaveRequest({
    this.stageName,
    this.description,
    this.profilePicture,
    this.instagramUrl,
    this.youtubeUrl,
    this.soundcloudUrl,
    this.spotifyEmbedUrl,
    this.instrumentIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'stageName': stageName,
    'description': description,
    'profilePicture': profilePicture,
    'instagramUrl': instagramUrl,
    'youtubeUrl': youtubeUrl,
    'soundcloudUrl': soundcloudUrl,
    'spotifyEmbedUrl': spotifyEmbedUrl,
    'instrumentIds': instrumentIds,
  };

  /// Opsiyonel: UI içinde kolay kopyalama için
  MusicianProfileSaveRequest copyWith({
    String? stageName,
    String? description,
    String? profilePicture,
    String? instagramUrl,
    String? youtubeUrl,
    String? soundcloudUrl,
    String? spotifyEmbedUrl,
    List<String>? instrumentIds,
  }) {
    return MusicianProfileSaveRequest(
      stageName: stageName ?? this.stageName,
      description: description ?? this.description,
      profilePicture: profilePicture ?? this.profilePicture,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      soundcloudUrl: soundcloudUrl ?? this.soundcloudUrl,
      spotifyEmbedUrl: spotifyEmbedUrl ?? this.spotifyEmbedUrl,
      instrumentIds: instrumentIds ?? this.instrumentIds,
    );
  }
}
