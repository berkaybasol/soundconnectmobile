class MusicianProfile {
  final String? stageName;
  final String? description;
  final String? profilePicture; // url/base64/key
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? soundcloudUrl;
  final String? spotifyEmbedUrl;
  final List<String> instruments;

  const MusicianProfile({
    this.stageName,
    this.description,
    this.profilePicture,
    this.instagramUrl,
    this.youtubeUrl,
    this.soundcloudUrl,
    this.spotifyEmbedUrl,
    this.instruments = const [],
  });

  factory MusicianProfile.fromAnyJson(Map<String, dynamic> json) {
    // BaseResponse<T> gelirse json["data"]'yı al; değilse direkt objeyi kullan
    final Map<String, dynamic> data =
    (json['data'] is Map<String, dynamic>) ? (json['data'] as Map<String, dynamic>) : json;

    return MusicianProfile(
      stageName: data['stageName'] as String?,
      description: data['description'] as String?,
      profilePicture: data['profilePicture'] as String?,
      instagramUrl: data['instagramUrl'] as String?,
      youtubeUrl: data['youtubeUrl'] as String?,
      soundcloudUrl: data['soundcloudUrl'] as String?,
      spotifyEmbedUrl: data['spotifyEmbedUrl'] as String?,
      instruments: _readInstruments(data['instruments']),
    );
  }

  static List<String> _readInstruments(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      // Destekle: ["Gitar","Piyano"] ya da [{"name":"Gitar"}, ...]
      return raw.map((e) {
        if (e is String) return e;
        if (e is Map && e['name'] != null) return e['name'].toString();
        return e.toString();
      }).toList();
    }
    return const [];
  }
}
