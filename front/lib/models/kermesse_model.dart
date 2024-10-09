class Kermesse {
  final int id;
  final String name;
  final String? invitationCode;

  Kermesse({
    required this.id,
    required this.name,
    this.invitationCode,
  });

  factory Kermesse.fromJson(Map<String, dynamic> json) {
    return Kermesse(
      id: json['id'],
      name: json['name'],
      invitationCode: json['invitation_code'],
    );
  }
}
