class VenueApplicationDraft {
  final String venueName;
  final String venueAddress;
  final String cityId;
  final String districtId;
  final String? neighborhoodId;

  const VenueApplicationDraft({
    required this.venueName,
    required this.venueAddress,
    required this.cityId,
    required this.districtId,
    this.neighborhoodId,
  });

  Map<String, dynamic> toCreateBody() => {
    'venueName': venueName,
    'venueAddress': venueAddress,
    'cityId': cityId,
    'districtId': districtId,
    'neighborhoodId': neighborhoodId,
  };
}
