import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/feed_post.dart';
import '../models/feed_comment.dart';
import '../models/radio_station.dart';
import '../services/feed_service.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/artwork.dart';
import '../widgets/gradient_top_bar.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: GradientTopBar(
                title: 'Feed',
                subtitle: 'SHARE & DISCOVER',
                height: 120,
                trailing: Container(
                  decoration: BoxDecoration(
                    color: WavelineColors.surface3,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WavelineColors.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showCreatePostSheet(context),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.add_rounded,
                          color: WavelineColors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Consumer<FeedService>(
                  builder: (context, feed, _) {
                    if (feed.posts.isEmpty) {
                      return _EmptyFeed();
                    }
                    return Column(
                      children: feed.posts.map((post) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FeedPostCard(post: post),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    final player = context.read<PlayerService>();
    if (!player.hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Play a station or episode first to share it',
            style: GoogleFonts.dmSans(fontSize: 13),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePostSheet(),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: WavelineColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WavelineColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rss_feed_rounded, size: 48, color: WavelineColors.textDim),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WavelineColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share what you\'re listening to\nwith the community',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 13, color: WavelineColors.textMuted),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const CreatePostSheet(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: WavelineColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: WavelineColors.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Create your first post',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: WavelineColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  final FeedPost post;

  const _FeedPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedService>();
    final isLiked = feed.isLiked(post.id, 'local_user');

    return Container(
      decoration: BoxDecoration(
        color: WavelineColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WavelineColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Text(
                post.caption,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: WavelineColors.textPrimary,
                ),
              ),
            ),
          _ContentPreview(post: post),
          if (post.type == FeedPostType.clip)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  Icon(Icons.content_cut_rounded, size: 14, color: WavelineColors.accent),
                  const SizedBox(width: 4),
                  Text(
                    'Clip ${_fmtDuration(post.clipStartMs)} - ${_fmtDuration(post.clipEndMs)}',
                    style: GoogleFonts.dmMono(
                      fontSize: 10,
                      color: WavelineColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                _ActionButton(
                  icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  label: '${post.likeCount}',
                  color: isLiked ? WavelineColors.pink : null,
                  onTap: () => feed.toggleLike(post.id, 'local_user'),
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.commentCount}',
                  onTap: () => _showComments(context, post),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(int? ms) {
    if (ms == null) return '0:00';
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showComments(BuildContext context, FeedPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(post: post),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final FeedPost post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: WavelineColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                post.userName.isNotEmpty ? post.userName[0].toUpperCase() : '?',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: WavelineColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: WavelineColors.textPrimary,
                  ),
                ),
                Text(
                  _formatTime(post.timestamp),
                  style: GoogleFonts.dmMono(
                    fontSize: 10,
                    color: WavelineColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: post.type == FeedPostType.clip
                  ? WavelineColors.accent.withValues(alpha: 0.1)
                  : WavelineColors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              post.type == FeedPostType.clip ? 'CLIP' : post.contentType.toUpperCase(),
              style: GoogleFonts.dmMono(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: post.type == FeedPostType.clip
                    ? WavelineColors.accent
                    : WavelineColors.cyan,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

class _ContentPreview extends StatelessWidget {
  final FeedPost post;
  const _ContentPreview({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Container(
        decoration: BoxDecoration(
          color: WavelineColors.surface3.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _playContent(context),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ArtworkWidget(
                    imageUrl: post.imageUrl,
                    emoji: post.emoji,
                    size: 44,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: WavelineColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          post.subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: WavelineColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WavelineColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 20,
                      color: WavelineColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _playContent(BuildContext context) {
    if (post.contentType == 'radio') {
      final station = RadioStation.seedStations
          .where((s) => s.id == post.contentId)
          .firstOrNull;
      if (station != null) {
        context.read<PlayerService>().playStation(station);
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? WavelineColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: color ?? WavelineColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _captionController = TextEditingController();
  bool _isClip = false;
  int? _clipStartMs;
  int? _clipEndMs;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final hasContent = player.hasContent;

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: WavelineColors.textDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share to Feed',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: WavelineColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (hasContent)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WavelineColors.surface3.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ArtworkWidget(
                        imageUrl: player.nowPlayingImageUrl,
                        emoji: player.nowPlayingEmoji,
                        size: 44,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.nowPlayingTitle,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: WavelineColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              player.nowPlayingSubtitle,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: WavelineColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WavelineColors.surface3.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Nothing playing right now',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: WavelineColors.textMuted,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _captionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  hintStyle: GoogleFonts.dmSans(fontSize: 13, color: WavelineColors.textDim),
                ),
                style: GoogleFonts.dmSans(fontSize: 13, color: WavelineColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (player.type == NowPlayingType.podcast)
                    GestureDetector(
                      onTap: () {
                        setState(() => _isClip = !_isClip);
                        if (_isClip) {
                          _clipStartMs = player.player.position.inMilliseconds;
                          _clipEndMs = (_clipStartMs! + 30000)
                              .clamp(0, player.player.duration?.inMilliseconds ?? _clipStartMs! + 30000);
                        } else {
                          _clipStartMs = null;
                          _clipEndMs = null;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isClip
                              ? WavelineColors.accent.withValues(alpha: 0.15)
                              : WavelineColors.surface3,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isClip
                                ? WavelineColors.accent.withValues(alpha: 0.3)
                                : WavelineColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.content_cut_rounded,
                              size: 16,
                              color: _isClip ? WavelineColors.accent : WavelineColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Clip',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: _isClip ? WavelineColors.accent : WavelineColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.maybeOf(context)?.pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: WavelineColors.surface3,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: WavelineColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _submit(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: WavelineColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Share',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final player = context.read<PlayerService>();
    final feed = context.read<FeedService>();

    final now = DateTime.now();
    final post = FeedPost(
      id: 'post_${now.millisecondsSinceEpoch}',
      userName: 'You',
      type: _isClip ? FeedPostType.clip : FeedPostType.recommendation,
      contentId: player.currentStation?.id ?? player.currentEpisode?.id ?? '',
      contentType: player.type == NowPlayingType.radio ? 'radio' : 'podcast',
      title: player.nowPlayingTitle,
      subtitle: player.nowPlayingSubtitle,
      emoji: player.nowPlayingEmoji,
      imageUrl: player.nowPlayingImageUrl,
      clipStartMs: _isClip ? _clipStartMs : null,
      clipEndMs: _isClip ? _clipEndMs : null,
      caption: _captionController.text.trim(),
      timestamp: now,
    );

    feed.addPost(post);
    Navigator.maybeOf(context)?.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Posted to feed!',
          style: GoogleFonts.dmSans(fontSize: 13),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final FeedPost post;
  const _CommentsSheet({required this.post});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();
  List<FeedComment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final feed = context.read<FeedService>();
    final comments = await feed.getComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: WavelineColors.gradientPlayer,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: WavelineColors.textDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Comments',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: WavelineColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_comments.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No comments yet. Be the first!',
                    style: GoogleFonts.dmSans(fontSize: 13, color: WavelineColors.textMuted),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _comments.length,
                    itemBuilder: (context, index) => _CommentRow(
                      comment: _comments[index],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: GoogleFonts.dmSans(fontSize: 13, color: WavelineColors.textDim),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      style: GoogleFonts.dmSans(fontSize: 13, color: WavelineColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendComment(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: WavelineColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendComment(BuildContext context) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final feed = context.read<FeedService>();
    final now = DateTime.now();
    final comment = FeedComment(
      id: 'comment_${now.millisecondsSinceEpoch}',
      postId: widget.post.id,
      userName: 'You',
      text: text,
      timestamp: now,
    );

    feed.addComment(comment);
    _commentController.clear();
    setState(() {
      _comments.add(comment);
    });
  }
}

class _CommentRow extends StatelessWidget {
  final FeedComment comment;
  const _CommentRow({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: WavelineColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: WavelineColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: WavelineColors.surface3.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.userName,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: WavelineColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(comment.timestamp),
                        style: GoogleFonts.dmMono(
                          fontSize: 9,
                          color: WavelineColors.textDim,
                        ),
                      ),
                    ],
                  ),
                  if (comment.text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      comment.text,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: WavelineColors.textSecondary,
                      ),
                    ),
                  ],
                  if (comment.hasAudio)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _AudioStickerPlayer(audioPath: comment.audioStickerPath!),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    return '${diff.inHours}h';
  }
}

class _AudioStickerPlayer extends StatefulWidget {
  final String audioPath;
  const _AudioStickerPlayer({required this.audioPath});

  @override
  State<_AudioStickerPlayer> createState() => _AudioStickerPlayerState();
}

class _AudioStickerPlayerState extends State<_AudioStickerPlayer> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isPlaying = !_isPlaying);
        // Audio playback would use just_audio or the record package's player
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: WavelineColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 14,
              color: WavelineColors.accent,
            ),
            const SizedBox(width: 4),
            Text(
              'Audio sticker',
              style: GoogleFonts.dmMono(
                fontSize: 9,
                color: WavelineColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
