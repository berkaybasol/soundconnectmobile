class IdName {
  final String id;
  final String name;

  const IdName({required this.id, required this.name});

  factory IdName.fromJson(Map<String, dynamic> j) {
    return IdName(
      id: j['id'].toString(),
      name: (j['name'] ?? '').toString(),
    );
  }
}
