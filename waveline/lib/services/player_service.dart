import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/radio_station.dart';
import '../models/podcast.dart';
import '../models/timeline_entry.dart';
import 'listening_history.dart';

enum NowPlayingType { none, radio, podcast }

class PlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  NowPlayingType _type = NowPlayingType.none;
  RadioStation? _currentStation;
  PodcastEpisode? _currentEpisode;
  bool _isLoading = false;
  String? _error;
  ListeningHistory? _history;

  set history(ListeningHistory? h) => _history = h;

  NowPlayingType get type => _type;
  RadioStation? get currentStation => _currentStation;
  PodcastEpisode? get currentEpisode => _currentEpisode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration> get durationStream => _player.durationStream
      .map((d) => d ?? Duration.zero);
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  String get nowPlayingTitle {
    switch (_type) {
      case NowPlayingType.radio:
        return _currentStation?.name ?? '';
      case NowPlayingType.podcast:
        return _currentEpisode?.title ?? '';
      case NowPlayingType.none:
        return '';
    }
  }

  String get nowPlayingSubtitle {
    switch (_type) {
      case NowPlayingType.radio:
        return _currentStation?.nowPlaying ?? _currentStation?.genre ?? '';
      case NowPlayingType.podcast:
        return _currentEpisode?.showTitle ?? '';
      case NowPlayingType.none:
        return '';
    }
  }

  String get nowPlayingEmoji {
    switch (_type) {
      case NowPlayingType.radio:
        return _currentStation?.emoji ?? '';
      case NowPlayingType.podcast:
        return _currentEpisode?.showEmoji ?? '';
      case NowPlayingType.none:
        return '';
    }
  }

  bool get hasContent => _type != NowPlayingType.none;

  Future<void> _setSource(String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> playStation(RadioStation station) async {
    await _player.stop();
    _type = NowPlayingType.radio;
    _currentStation = station;
    _currentEpisode = null;
    await _setSource(station.streamUrl);
    await _player.play();
    _history?.addEntry(TimelineEntry(
      id: station.id,
      title: station.name,
      subtitle: station.genre,
      emoji: station.emoji,
      type: 'radio',
      playedAt: DateTime.now(),
    ));
  }

  Future<void> playEpisode(PodcastEpisode episode) async {
    await _player.stop();
    _type = NowPlayingType.podcast;
    _currentEpisode = episode;
    _currentStation = null;
    await _setSource(episode.audioUrl);
    await _player.play();
    _history?.addEntry(TimelineEntry(
      id: episode.id,
      title: episode.title,
      subtitle: episode.showTitle,
      emoji: episode.showEmoji,
      type: 'podcast',
      playedAt: DateTime.now(),
    ));
  }

  Future<void> togglePlay() async {
    if (!hasContent) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> skipForward() async {
    final newPos = (_player.position + const Duration(seconds: 15));
    await _player.seek(newPos);
  }

  Future<void> skipBack() async {
    final newPos = (_player.position - const Duration(seconds: 15));
    await _player.seek(newPos);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
    _type = NowPlayingType.none;
    _currentStation = null;
    _currentEpisode = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
