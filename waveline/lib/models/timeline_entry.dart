enum TimelineEntryType { radio, podcast }

class TimelineEntry {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final TimelineEntryType type;
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
        'type': type.name,
        'playedAt': playedAt.toIso8601String(),
      };

  factory TimelineEntry.fromJson(Map<String, dynamic> json) => TimelineEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        emoji: json['emoji'] as String,
        type: TimelineEntryType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TimelineEntryType.radio,
        ),
        playedAt: DateTime.parse(json['playedAt'] as String),
      );
}
