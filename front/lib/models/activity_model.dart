class Activity {
  final int id;
  final String name;
  final String type;
  final String? emoji;
  final int price;
  final int points;

  Activity({
    required this.id,
    required this.name,
    required this.type,
    this.emoji,
    required this.price,
    required this.points,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      emoji: json['emoji'],
      price: json['price'],
      points: json['points'],
    );
  }

  // Convertir une instance d'Activity en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'emoji': emoji,
      'price': price,
      'points': points,
    };
  }
}
