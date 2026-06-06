import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../services/player_service.dart';
import '../../services/favorite_service.dart';
import '../../theme/app_theme.dart';
import '../artwork.dart';
import '../queue_sheet.dart';
import '../responsive.dart';
import '../../screens/feed_screen.dart';
import 'wavy_slider.dart';
import 'animated_playback_controls.dart';

class FullPlayerSheet extends StatefulWidget {
  final VoidCallback? onCollapse;

  const FullPlayerSheet({super.key, this.onCollapse});

  @override
  State<FullPlayerSheet> createState() => _FullPlayerSheetState();
}

class _FullPlayerSheetState extends State<FullPlayerSheet> {
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  double _sliderValue = 0;
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    final player = context.read<PlayerService>();
    _posSub = player.positionStream.listen((pos) {
      if (!_isSeeking && mounted) {
        setState(() {
          _position = pos;
          _updateSlider();
        });
      }
    });
    _durSub = player.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
    _stateSub = player.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
  }

  void _updateSlider() {
    if (_duration.inMilliseconds > 0) {
      _sliderValue = _position.inMilliseconds / _duration.inMilliseconds;
    }
  }

  void _onSliderChanged(double value) {
    _isSeeking = true;
    setState(() => _sliderValue = value);
  }

  void _onSliderChangeEnd(double value) {
    _isSeeking = false;
    final player = context.read<PlayerService>();
    final pos = Duration(milliseconds: (value * _duration.inMilliseconds).round());
    player.seek(pos);
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: WavelineColors.gradientPlayer,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 8),
          child: Column(
            children: [
              GestureDetector(
                onTap: widget.onCollapse,
                child: _DragHandle(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _AlbumArtSection(player: player),
                      const SizedBox(height: 20),
                      _TrackInfo(player: player),
                      if (player.isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: WavelineColors.accent,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Buffering',
                                style: GoogleFonts.dmMono(
                                  fontSize: 10,
                                  color: WavelineColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (player.type == NowPlayingType.podcast) ...[
                        _SeekBar(
                          value: _sliderValue,
                          onChanged: _onSliderChanged,
                          onChangeEnd: _onSliderChangeEnd,
                          isPlaying: _isPlaying,
                        ),
                        const SizedBox(height: 4),
                        _TimeLabels(position: _position, duration: _duration),
                        const SizedBox(height: 8),
                      ],
                      AnimatedPlaybackControls(
                        isPlaying: _isPlaying,
                        onPrevious: () => player.skipBack(),
                        onPlayPause: () => player.togglePlay(),
                        onNext: () => player.skipForward(),
                      ),
                      const SizedBox(height: 16),
                      if (player.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Playback error: ${player.error}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: WavelineColors.pink,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      _BottomActions(player: player),
                    ],
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

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: WavelineColors.textDim,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _AlbumArtSection extends StatelessWidget {
  final PlayerService player;

  const _AlbumArtSection({required this.player});

  @override
  Widget build(BuildContext context) {
    final artSize = Responsive(context).albumArtSize;
    return Container(
      width: artSize,
      height: artSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WavelineColors.accent.withValues(alpha: 0.15),
            WavelineColors.surface3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: WavelineColors.border),
        boxShadow: [
          BoxShadow(
            color: WavelineColors.accentBright.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: ArtworkWidget(
          imageUrl: player.nowPlayingImageUrl,
          emoji: player.nowPlayingEmoji,
          size: artSize,
          borderRadius: 23,
        ),
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  final PlayerService player;

  const _TrackInfo({required this.player});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: player.type == NowPlayingType.radio
                ? WavelineColors.cyan.withValues(alpha: 0.15)
                : WavelineColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            player.type == NowPlayingType.radio ? 'RADIO' : 'PODCAST',
            style: GoogleFonts.dmMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: player.type == NowPlayingType.radio
                  ? WavelineColors.cyan
                  : WavelineColors.accent,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          player.nowPlayingTitle,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: WavelineColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          player.nowPlayingSubtitle,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: WavelineColors.textMuted,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SeekBar extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;
  final bool isPlaying;

  const _SeekBar({
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return WavySlider(
      value: value,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      isPlaying: isPlaying,
    );
  }
}

class _TimeLabels extends StatelessWidget {
  final Duration position;
  final Duration duration;

  const _TimeLabels({required this.position, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _fmt(position),
            style: GoogleFonts.dmMono(fontSize: 11, color: WavelineColors.textMuted),
          ),
          Text(
            _fmt(duration),
            style: GoogleFonts.dmMono(fontSize: 11, color: WavelineColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _BottomActions extends StatelessWidget {
  final PlayerService player;

  const _BottomActions({required this.player});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoriteService>();
    final currentId = player.currentStation?.id ?? player.currentEpisode?.id ?? '';
    final isFav = currentId.isNotEmpty && fav.isFavorite(currentId);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          iconColor: isFav ? WavelineColors.pink : null,
          onTap: () {
            if (currentId.isNotEmpty) fav.toggleFavorite(currentId);
          },
        ),
        if (player.type == NowPlayingType.podcast)
          _ActionButton(icon: Icons.speed_outlined),
        _ActionButton(
          icon: Icons.queue_music_rounded,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const QueueSheet(),
            );
          },
        ),
        _ActionButton(
          icon: Icons.lyrics_outlined,
        ),
        _ActionButton(
          icon: Icons.share_rounded,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CreatePostSheet(),
            );
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WavelineColors.surface3.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              color: iconColor ?? WavelineColors.textMuted,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
