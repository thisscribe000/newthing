import 'radio_station.dart';
import 'podcast.dart';

sealed class QueueItem {
  String get id;
  String get title;
  String get subtitle;
  String get emoji;
  String get imageUrl;
}

class StationQueueItem extends QueueItem {
  final RadioStation station;

  StationQueueItem(this.station);

  @override
  String get id => station.id;

  @override
  String get title => station.name;

  @override
  String get subtitle => '${station.genre} \u00b7 ${station.country}';

  @override
  String get emoji => station.emoji;

  @override
  String get imageUrl => station.imageUrl;
}

class EpisodeQueueItem extends QueueItem {
  final PodcastEpisode episode;

  EpisodeQueueItem(this.episode);

  @override
  String get id => episode.id;

  @override
  String get title => episode.title;

  @override
  String get subtitle => episode.showTitle;

  @override
  String get emoji => episode.showEmoji;

  @override
  String get imageUrl => episode.imageUrl;
}
