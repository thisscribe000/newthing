class RadioStation {
  final String id;
  final String name;
  final String genre;
  final String country;
  final String streamUrl;
  final String imageUrl;
  final String emoji;
  final int listeners;
  final String nowPlaying;

  const RadioStation({
    required this.id,
    required this.name,
    required this.genre,
    required this.country,
    required this.streamUrl,
    required this.imageUrl,
    required this.emoji,
    this.listeners = 0,
    this.nowPlaying = '',
  });

  static const List<RadioStation> seedStations = [
    RadioStation(
      id: 'city_fm',
      name: 'City FM',
      genre: 'Top 40',
      country: 'Nigeria',
      streamUrl: 'https://stream.zeno.fm/0r0xa792kwzuv',
      imageUrl: '',
      emoji: '🏙️',
      listeners: 1243,
      nowPlaying: 'Afrobeats Mix',
    ),
    RadioStation(
      id: 'afrobeats_radio',
      name: 'Afrobeats Radio',
      genre: 'Afrobeats',
      country: 'Nigeria',
      streamUrl: 'https://stream.zeno.fm/f3wvbbqmdg8uv',
      imageUrl: '',
      emoji: '🕺🏾',
      listeners: 2891,
      nowPlaying: 'Burna Boy - Last Last',
    ),
    RadioStation(
      id: 'bbc_world',
      name: 'BBC World Service',
      genre: 'News',
      country: 'UK',
      streamUrl: 'https://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
      imageUrl: '',
      emoji: '🌍',
      listeners: 5621,
      nowPlaying: 'Global News Report',
    ),
    RadioStation(
      id: 'gospel_947',
      name: 'Gospel 94.7',
      genre: 'Gospel',
      country: 'Nigeria',
      streamUrl: 'https://stream.zeno.fm/yn65m0qmdg8uv',
      imageUrl: '',
      emoji: '🙌🏾',
      listeners: 987,
      nowPlaying: 'Mercy Chinwo - Excess Love',
    ),
    RadioStation(
      id: 'classic_rock',
      name: 'Classic Rock FM',
      genre: 'Rock',
      country: 'International',
      streamUrl: 'https://stream.zeno.fm/4d61wp0mdg8uv',
      imageUrl: '',
      emoji: '🎸',
      listeners: 1765,
      nowPlaying: 'Queen - Bohemian Rhapsody',
    ),
  ];
}
