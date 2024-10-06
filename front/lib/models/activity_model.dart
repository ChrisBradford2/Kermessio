class Activity {
  final int id;
  final String name;
  final String type;
  final String? emoji; // Peut être null
  final int price;
  final int points;
  final int boothHolderId;
  final int kermesseId;  // Ajout du champ KermesseID

  Activity({
    required this.id,
    required this.name,
    required this.type,
    this.emoji,
    required this.price,
    required this.points,
    required this.boothHolderId,
    required this.kermesseId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      emoji: json['emoji'],
      price: json['price'],
      points: json['points'],
      boothHolderId: json['booth_holder_id'],
      kermesseId: json['kermesse_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'emoji': emoji,
      'price': price,
      'points': points,
      'booth_holder_id': boothHolderId,
      'kermesse_id': kermesseId,
    };
  }
}
