class NotificationEntity {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final String payload;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.payload,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      payload: json['payload'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
      'payload': payload,
    };
  }

}
