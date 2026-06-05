import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/podcast_clip.dart';

class ClipService extends ChangeNotifier {
  static const _key = 'saved_clips';
  List<PodcastClip> _clips = [];

  List<PodcastClip> get clips => List.unmodifiable(_clips);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _clips = list
          .map((e) => PodcastClip.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> saveClip(PodcastClip clip) async {
    _clips.insert(0, clip);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteClip(String id) async {
    _clips.removeWhere((c) => c.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_clips.map((c) => c.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
