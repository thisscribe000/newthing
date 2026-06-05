class TimelineEntry {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String type; // 'radio' or 'podcast'
  final DateTime playedAt;

  const TimelineEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.type,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'emoji': emoji,
        'type': type,
        'playedAt': playedAt.toIso8601String(),
      };

  factory TimelineEntry.fromJson(Map<String, dynamic> json) => TimelineEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        emoji: json['emoji'] as String,
        type: json['type'] as String,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );
}
