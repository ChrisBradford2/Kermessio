class BoothHolder {
  final String username;
  final int x;
  final int y;

  BoothHolder({required this.username, required this.x, required this.y});

  factory BoothHolder.fromJson(Map<String, dynamic> json) {
    return BoothHolder(
      username: json['username'],
      x: json['x'],
      y: json['y'],
    );
  }
}
