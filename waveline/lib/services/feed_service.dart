import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feed_post.dart';
import '../models/feed_comment.dart';
import '../models/radio_station.dart';

class FeedService extends ChangeNotifier {
  static const _postsKey = 'feed_posts';
  static const _commentsPrefix = 'feed_comments_';

  List<FeedPost> _posts = [];

  List<FeedPost> get posts => List.unmodifiable(_posts);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_postsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _posts = list
            .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _posts = [];
    }
    if (_posts.isEmpty) {
      await _seedDummyData();
    }
    notifyListeners();
  }

  Future<void> _seedDummyData() async {
    final now = DateTime.now();
    final stations = RadioStation.seedStations;
    _posts = [
      FeedPost(
        id: 'seed_1',
        userName: 'You',
        type: FeedPostType.recommendation,
        contentId: stations[1].id,
        contentType: 'radio',
        title: stations[1].name,
        subtitle: stations[1].genre,
        emoji: stations[1].emoji,
        imageUrl: stations[1].imageUrl,
        caption: 'The best Afrobeats mix to start your morning! 🔥',
        timestamp: now.subtract(const Duration(minutes: 15)),
        likes: ['local_user'],
        commentCount: 2,
      ),
      FeedPost(
        id: 'seed_2',
        userName: 'You',
        type: FeedPostType.clip,
        contentId: stations[0].id,
        contentType: 'radio',
        title: stations[0].name,
        subtitle: 'Energy for the day 🚀',
        emoji: stations[0].emoji,
        imageUrl: stations[0].imageUrl,
        clipStartMs: 30000,
        clipEndMs: 60000,
        caption: 'This part hits different!',
        timestamp: now.subtract(const Duration(hours: 2)),
        likes: [],
        commentCount: 0,
      ),
      FeedPost(
        id: 'seed_3',
        userName: 'You',
        type: FeedPostType.recommendation,
        contentId: stations[4].id,
        contentType: 'radio',
        title: stations[4].name,
        subtitle: stations[4].genre,
        emoji: stations[4].emoji,
        imageUrl: stations[4].imageUrl,
        caption: 'Sunday vibes with Classic Rock 🎸',
        timestamp: now.subtract(const Duration(days: 1)),
        likes: ['local_user', 'friend_1'],
        commentCount: 3,
      ),
    ];
    await _persistPosts();
  }

  Future<void> addPost(FeedPost post) async {
    _posts.insert(0, post);
    await _persistPosts();
    notifyListeners();
  }

  Future<void> deletePost(String id) async {
    _posts.removeWhere((p) => p.id == id);
    await _persistPosts();
    notifyListeners();
  }

  Future<void> toggleLike(String postId, String userId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final updatedLikes = List<String>.from(post.likes);
    if (updatedLikes.contains(userId)) {
      updatedLikes.remove(userId);
    } else {
      updatedLikes.add(userId);
    }

    _posts[index] = FeedPost(
      id: post.id,
      userName: post.userName,
      type: post.type,
      contentId: post.contentId,
      contentType: post.contentType,
      title: post.title,
      subtitle: post.subtitle,
      emoji: post.emoji,
      imageUrl: post.imageUrl,
      clipStartMs: post.clipStartMs,
      clipEndMs: post.clipEndMs,
      caption: post.caption,
      timestamp: post.timestamp,
      likes: updatedLikes,
      commentCount: post.commentCount,
    );
    await _persistPosts();
    notifyListeners();
  }

  bool isLiked(String postId, String userId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return false;
    return _posts[index].likes.contains(userId);
  }

  Future<void> addComment(FeedComment comment) async {
    final index = _posts.indexWhere((p) => p.id == comment.postId);
    if (index == -1) return;

    final prefs = await SharedPreferences.getInstance();
    final commentsKey = _commentsPrefix + comment.postId;
    final raw = prefs.getString(commentsKey);
    final comments = raw != null
        ? (jsonDecode(raw) as List)
            .map((e) => FeedComment.fromJson(e as Map<String, dynamic>))
            .toList()
        : <FeedComment>[];
    comments.add(comment);
    await prefs.setString(commentsKey, jsonEncode(comments.map((c) => c.toJson()).toList()));

    final post = _posts[index];
    _posts[index] = FeedPost(
      id: post.id,
      userName: post.userName,
      type: post.type,
      contentId: post.contentId,
      contentType: post.contentType,
      title: post.title,
      subtitle: post.subtitle,
      emoji: post.emoji,
      imageUrl: post.imageUrl,
      clipStartMs: post.clipStartMs,
      clipEndMs: post.clipEndMs,
      caption: post.caption,
      timestamp: post.timestamp,
      likes: post.likes,
      commentCount: comments.length,
    );
    await _persistPosts();
    notifyListeners();
  }

  Future<List<FeedComment>> getComments(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_commentsPrefix + postId);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => FeedComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _persistPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_posts.map((p) => p.toJson()).toList());
    await prefs.setString(_postsKey, raw);
  }
}
