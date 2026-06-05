import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timeline_entry.dart';

class ListeningHistory extends ChangeNotifier {
  static const _key = 'listening_history';
  List<TimelineEntry> _entries = [];

  List<TimelineEntry> get entries => List.unmodifiable(_entries);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _entries = list
          .map((e) => TimelineEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> addEntry(TimelineEntry entry) async {
    _entries.insert(0, entry);
    if (_entries.length > 50) {
      _entries = _entries.sublist(0, 50);
    }
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
