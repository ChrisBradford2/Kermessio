import 'package:front/models/user_model.dart';

class Participation {
  final int id;
  final int userId;
  final User user;
  final int activityId;
  final int points;
  final bool isWinner;

  Participation({
    required this.id,
    required this.userId,
    required this.user,
    required this.activityId,
    required this.points,
    required this.isWinner,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'],
      userId: json['user_id'],
      user: User.fromJson(json['user']),
      activityId: json['activity_id'],
      points: json['points'],
      isWinner: json['is_winner'],
    );
  }
}
