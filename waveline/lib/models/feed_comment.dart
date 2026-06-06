class FeedComment {
  final String id;
  final String postId;
  final String userName;
  final String text;
  final String? audioStickerPath;
  final Duration? audioStickerDuration;
  final DateTime timestamp;

  const FeedComment({
    required this.id,
    required this.postId,
    required this.userName,
    this.text = '',
    this.audioStickerPath,
    this.audioStickerDuration,
    required this.timestamp,
  });

  bool get hasAudio => audioStickerPath != null && audioStickerPath!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'userName': userName,
        'text': text,
        'audioStickerPath': audioStickerPath,
        'audioStickerDurationMs': audioStickerDuration?.inMilliseconds,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FeedComment.fromJson(Map<String, dynamic> json) => FeedComment(
        id: json['id'] as String,
        postId: json['postId'] as String,
        userName: json['userName'] as String,
        text: (json['text'] as String?) ?? '',
        audioStickerPath: json['audioStickerPath'] as String?,
        audioStickerDuration: json['audioStickerDurationMs'] != null
            ? Duration(milliseconds: json['audioStickerDurationMs'] as int)
            : null,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
