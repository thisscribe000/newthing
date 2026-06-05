class PodcastShow {
  final String id;
  final String title;
  final String author;
  final String rssUrl;
  final String imageUrl;
  final String emoji;
  final String category;

  const PodcastShow({
    required this.id,
    required this.title,
    required this.author,
    required this.rssUrl,
    required this.imageUrl,
    required this.emoji,
    required this.category,
  });

  static const List<PodcastShow> seedShows = [
    PodcastShow(
      id: 'the_daily',
      title: 'The Daily',
      author: 'The New York Times',
      rssUrl: 'https://feeds.simplecast.com/54nAGcIl',
      imageUrl: '',
      emoji: '📰',
      category: 'News',
    ),
    PodcastShow(
      id: 'how_i_built_this',
      title: 'How I Built This',
      author: 'NPR',
      rssUrl: 'https://feeds.npr.org/510313/podcast.xml',
      imageUrl: '',
      emoji: '🏗️',
      category: 'Business',
    ),
    PodcastShow(
      id: 'lex_fridman',
      title: 'Lex Fridman Podcast',
      author: 'Lex Fridman',
      rssUrl: 'https://lexfridman.com/feed/podcast/',
      imageUrl: '',
      emoji: '🤖',
      category: 'Technology',
    ),
    PodcastShow(
      id: 'huberman_lab',
      title: 'Huberman Lab',
      author: 'Andrew Huberman',
      rssUrl: 'https://feeds.megaphone.fm/hubermanlab',
      imageUrl: '',
      emoji: '🧠',
      category: 'Science',
    ),
  ];
}

class PodcastEpisode {
  final String id;
  final String showTitle;
  final String showEmoji;
  final String title;
  final String description;
  final String audioUrl;
  final Duration duration;
  final DateTime publishedAt;
  final String imageUrl;

  const PodcastEpisode({
    required this.id,
    required this.showTitle,
    required this.showEmoji,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.duration,
    required this.publishedAt,
    required this.imageUrl,
  });

  String get durationFormatted {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m ${s}s';
  }

  String get publishedFormatted {
    final now = DateTime.now();
    final diff = now.difference(publishedAt);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    }
    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inMinutes}m ago';
  }
}
