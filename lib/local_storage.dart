import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class LocalStorage {
  static const String _playlistsKey = 'playlists_data';
  static const String _favoritesKey = 'favorites_data';

  Future<List<Playlist>> getAllPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_playlistsKey);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((json) => Playlist.fromJson(json)).toList();
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playlistsKey, jsonEncode(playlists.map((p) => p.toJson()).toList()));
  }

  Future<void> updatePlaylist(Playlist updatedPlaylist) async {
    final playlists = await getAllPlaylists();
    final index = playlists.indexWhere((p) => p.id == updatedPlaylist.id);
    if (index != -1) {
      playlists[index] = updatedPlaylist;
      await savePlaylists(playlists);
    }
  }

  Future<void> deletePlaylist(String id) async {
    final playlists = await getAllPlaylists();
    playlists.removeWhere((p) => p.id == id);
    await savePlaylists(playlists);
  }

  Future<List<String>> getFavoriteSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> saveFavoriteSongIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playlistsKey);
    await prefs.remove(_favoritesKey);
  }
}