class Participation {
  final int id;
  final int userId;
  final int activityId;
  final int points;
  final bool isWinner;

  Participation({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.points,
    required this.isWinner,
  });

  // Convertir un JSON en instance de Participation
  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'],
      userId: json['user_id'],
      activityId: json['activity_id'],
      points: json['points'],
      isWinner: json['is_winner'],
    );
  }
}
