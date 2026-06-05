import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import '../models/podcast.dart';

class PodcastService {
  final Map<String, List<PodcastEpisode>> _cache = {};
  final http.Client _client = http.Client();

  Future<List<PodcastEpisode>> fetchEpisodes(PodcastShow show,
      {int limit = 20}) async {
    if (_cache.containsKey(show.id)) {
      return _cache[show.id]!;
    }

    try {
      final response = await _client.get(Uri.parse(show.rssUrl));
      if (response.statusCode != 200) {
        return [];
      }

      final utf8Body = utf8.decode(response.bodyBytes);
      final feed = RssFeed.parse(utf8Body);
      final items = feed.items ?? [];
      final episodes = <PodcastEpisode>[];

      for (final item in items.take(limit)) {
        final audioUrl = item.enclosure?.url ?? '';
        if (audioUrl.isEmpty) continue;

        final id = item.guid ?? item.link ?? audioUrl;
        final duration = item.itunes?.duration ?? Duration.zero;
        final publishedAt = item.pubDate ?? DateTime.now();
        final imageUrl = item.itunes?.image?.href ??
            feed.itunes?.image?.href ??
            '';
        final description = _stripHtml(item.description ?? '');
        final title = item.title ?? 'Untitled';

        episodes.add(PodcastEpisode(
          id: id,
          showTitle: show.title,
          showEmoji: show.emoji,
          title: title,
          description: description,
          audioUrl: audioUrl,
          duration: duration,
          publishedAt: publishedAt,
          imageUrl: imageUrl,
        ));
      }

      _cache[show.id] = episodes;
      return episodes;
    } catch (e) {
      return [];
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void clearCache() {
    _cache.clear();
  }

  void dispose() {
    _client.close();
  }
}
