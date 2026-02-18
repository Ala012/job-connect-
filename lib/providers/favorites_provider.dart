import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  List<String> _favoriteJobIds = [];

  List<String> get favoriteJobIds => _favoriteJobIds;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favoriteJobIds') ?? [];
    _favoriteJobIds = savedFavorites;
    notifyListeners();
  }

  Future<void> toggleFavorite(String jobId) async {
    if (_favoriteJobIds.contains(jobId)) {
      await removeFavorite(jobId);
    } else {
      await addFavorite(jobId);
    }
  }

  Future<void> addFavorite(String jobId) async {
    if (!_favoriteJobIds.contains(jobId)) {
      _favoriteJobIds.add(jobId);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String jobId) async {
    if (_favoriteJobIds.contains(jobId)) {
      _favoriteJobIds.remove(jobId);
      await _saveFavorites();
      notifyListeners();
    }
  }

  bool isFavorite(String jobId) {
    return _favoriteJobIds.contains(jobId);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteJobIds', _favoriteJobIds);
  }

  Future<void> clearAll() async {
    _favoriteJobIds.clear();
    await _saveFavorites();
    notifyListeners();
  }
}
