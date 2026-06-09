import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/radio_station.dart';
import '../models/podcast.dart';
import '../theme/app_theme.dart';
import '../widgets/station_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<RadioStation> get _filteredStations {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return RadioStation.seedStations.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.genre.toLowerCase().contains(q) ||
          s.country.toLowerCase().contains(q) ||
          s.nowPlaying.toLowerCase().contains(q);
    }).toList();
  }

  List<PodcastShow> get _filteredShows {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return PodcastShow.seedShows.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.author.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasResults = _filteredStations.isNotEmpty || _filteredShows.isNotEmpty;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    WavelineColors.accentDark.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 16),
              child: Text(
                'Search',
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: WavelineColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search stations, podcasts...',
                      prefixIcon: Icon(Icons.search_rounded, color: WavelineColors.textDim),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, color: WavelineColors.textDim),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                    ),
                    style: GoogleFonts.dmSans(fontSize: 14, color: WavelineColors.textPrimary),
                  ),
                  const SizedBox(height: 24),
                  if (_query.isEmpty)
                    _CategoriesGrid()
                  else if (!hasResults)
                    _NoResults(query: _query)
                  else ...[
                    if (_filteredStations.isNotEmpty) ...[
                      _SectionLabel('Radio Stations'),
                      const SizedBox(height: 10),
                      ..._filteredStations.map((s) => StationCard(
                        station: s,
                        compact: true,
                      )),
                      const SizedBox(height: 16),
                    ],
                    if (_filteredShows.isNotEmpty) ...[
                      _SectionLabel('Podcasts'),
                      const SizedBox(height: 10),
                      ..._filteredShows.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ShowResult(show: s),
                      )),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      {'emoji': '🎵', 'label': 'Afrobeats', 'color': WavelineColors.accent},
      {'emoji': '🎸', 'label': 'Rock', 'color': WavelineColors.pink},
      {'emoji': '📰', 'label': 'News', 'color': WavelineColors.cyan},
      {'emoji': '🙌', 'label': 'Gospel', 'color': WavelineColors.gold},
      {'emoji': '🧠', 'label': 'Science', 'color': WavelineColors.orange},
      {'emoji': '💼', 'label': 'Business', 'color': WavelineColors.accentLight},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Browse Categories'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final itemW = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: categories.map((cat) {
                return Container(
                  width: itemW,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (cat['color'] as Color).withValues(alpha: 0.15),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Text(cat['emoji'] as String, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          cat['label'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: WavelineColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 11,
        letterSpacing: 1.5,
        color: WavelineColors.textMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.search_off_rounded, size: 48, color: WavelineColors.textDim),
          const SizedBox(height: 12),
          Text(
            'No results for "$query"',
            style: GoogleFonts.dmSans(fontSize: 14, color: WavelineColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ShowResult extends StatelessWidget {
  final PodcastShow show;
  const _ShowResult({required this.show});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WavelineColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WavelineColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: WavelineColors.surface3,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(show.emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      show.title,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: WavelineColors.textPrimary,
                      ),
                    ),
                    Text(
                      show.author,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: WavelineColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: WavelineColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Explore',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: WavelineColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
