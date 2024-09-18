class Kermesse {
  final int id;
  final String name;

  Kermesse({
    required this.id,
    required this.name,
  });

  factory Kermesse.fromJson(Map<String, dynamic> json) {
    return Kermesse(
      id: json['id'],
      name: json['name'],
    );
  }
}
