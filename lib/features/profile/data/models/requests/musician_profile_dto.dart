// lib/features/profile/data/models/musician_profile_dto.dart
class MusicianProfileDto {
  final String? id;
  final String? stageName;
  final String? bio;
  final String? profilePicture;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? soundcloudUrl;
  final String? spotifyEmbedUrl;
  final List<String> instruments;
  final List<String> activeVenues;

  const MusicianProfileDto({
    this.id,
    this.stageName,
    this.bio,
    this.profilePicture,
    this.instagramUrl,
    this.youtubeUrl,
    this.soundcloudUrl,
    this.spotifyEmbedUrl,
    this.instruments = const [],
    this.activeVenues = const [],
  });

  factory MusicianProfileDto.fromJson(Map<String, dynamic> j) {
    List<String> _list(dynamic v) =>
        (v is List) ? v.map((e) => e.toString()).toList() : const [];
    return MusicianProfileDto(
      id: j['id']?.toString(),
      stageName: j['stageName']?.toString(),
      bio: j['bio']?.toString(),
      profilePicture: j['profilePicture']?.toString(),
      instagramUrl: j['instagramUrl']?.toString(),
      youtubeUrl: j['youtubeUrl']?.toString(),
      soundcloudUrl: j['soundcloudUrl']?.toString(),
      spotifyEmbedUrl: j['spotifyEmbedUrl']?.toString(),
      instruments: _list(j['instruments']),
      activeVenues: _list(j['activeVenues']),
    );
  }
}
