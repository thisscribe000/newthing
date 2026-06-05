class PodcastClip {
  final String id;
  final String episodeId;
  final String episodeTitle;
  final String showTitle;
  final String showEmoji;
  final Duration startTime;
  final Duration endTime;
  final DateTime createdAt;

  const PodcastClip({
    required this.id,
    required this.episodeId,
    required this.episodeTitle,
    required this.showTitle,
    required this.showEmoji,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  String get durationFormatted {
    final d = endTime - startTime;
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${m}m ${s}s';
  }

  String get timeRangeFormatted {
    return '${_fmt(startTime)} - ${_fmt(endTime)}';
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'episodeId': episodeId,
        'episodeTitle': episodeTitle,
        'showTitle': showTitle,
        'showEmoji': showEmoji,
        'startTimeMs': startTime.inMilliseconds,
        'endTimeMs': endTime.inMilliseconds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PodcastClip.fromJson(Map<String, dynamic> json) => PodcastClip(
        id: json['id'] as String,
        episodeId: json['episodeId'] as String,
        episodeTitle: json['episodeTitle'] as String,
        showTitle: json['showTitle'] as String,
        showEmoji: json['showEmoji'] as String,
        startTime: Duration(milliseconds: json['startTimeMs'] as int),
        endTime: Duration(milliseconds: json['endTimeMs'] as int),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
