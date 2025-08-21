class Instrument {
  final String id;
  final String name;

  const Instrument({required this.id, required this.name});

  factory Instrument.fromJson(Map<String, dynamic> json) {
    return Instrument(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}
