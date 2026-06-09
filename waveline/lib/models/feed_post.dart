enum FeedPostType { recommendation, clip }

class FeedPost {
  final String id;
  final String userName;
  final FeedPostType type;
  final String contentId;
  final String contentType;
  final String title;
  final String subtitle;
  final String emoji;
  final String imageUrl;
  final String? audioUrl;
  final int? clipStartMs;
  final int? clipEndMs;
  final String caption;
  final DateTime timestamp;
  final List<String> likes;
  final int commentCount;

  const FeedPost({
    required this.id,
    required this.userName,
    required this.type,
    required this.contentId,
    required this.contentType,
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.imageUrl = '',
    this.audioUrl,
    this.clipStartMs,
    this.clipEndMs,
    this.caption = '',
    required this.timestamp,
    this.likes = const [],
    this.commentCount = 0,
  });

  int get likeCount => likes.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'type': type.name,
        'contentId': contentId,
        'contentType': contentType,
        'title': title,
        'subtitle': subtitle,
        'emoji': emoji,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'clipStartMs': clipStartMs,
        'clipEndMs': clipEndMs,
        'caption': caption,
        'timestamp': timestamp.toIso8601String(),
        'likes': likes,
        'commentCount': commentCount,
      };

  factory FeedPost.fromJson(Map<String, dynamic> json) => FeedPost(
        id: json['id'] as String,
        userName: json['userName'] as String,
        type: FeedPostType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => FeedPostType.recommendation,
        ),
        contentId: json['contentId'] as String,
        contentType: json['contentType'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        emoji: json['emoji'] as String,
        imageUrl: (json['imageUrl'] as String?) ?? '',
        audioUrl: json['audioUrl'] as String?,
        clipStartMs: json['clipStartMs'] as int?,
        clipEndMs: json['clipEndMs'] as int?,
        caption: (json['caption'] as String?) ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
        likes: (json['likes'] as List?)?.cast<String>() ?? [],
        commentCount: (json['commentCount'] as int?) ?? 0,
      );
}
