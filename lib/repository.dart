import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'auth_service.dart';

class Repository {
  static const String baseUrl = 'http://192.168.0.188:3000/api';
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  // ══ PLAYLISTS ══

  Future<List<Playlist>> getPlaylists() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/playlists'), headers: await _headers());
      if (res.statusCode != 200) return [];
      return (jsonDecode(res.body) as List).map((j) => Playlist.fromJson(j)).toList();
    } catch (_) { return []; }
  }

  Future<void> addPlaylist(Playlist playlist) async {
    try {
      await http.post(Uri.parse('$baseUrl/playlists'),
          headers: await _headers(), body: jsonEncode(playlist.toJson()));
    } catch (_) {}
  }

  Future<void> syncPlaylist(Playlist p) async {
    try {
      await http.post(Uri.parse('$baseUrl/playlists/sync'),
          headers: await _headers(), body: jsonEncode(p.toJson()));
    } catch (_) {}
  }

  Future<void> removePlaylist(String id) async {
    try {
      await http.delete(Uri.parse('$baseUrl/playlists/$id'), headers: await _headers());
    } catch (_) {}
  }

  // ══ FAVORITES ══

  Future<List<String>> getFavorites() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/favorites'), headers: await _headers());
      if (res.statusCode != 200) return [];
      return List<String>.from(jsonDecode(res.body));
    } catch (_) { return []; }
  }

  Future<void> toggleFavorite(String songId, {String? title, String? artist}) async {
    try {
      await http.post(Uri.parse('$baseUrl/favorites/toggle'),
          headers: await _headers(), body: jsonEncode({'songId': songId}));
    } catch (_) {}
  }

  // ══ ACTIVITY ══

  Future<List<Map<String, dynamic>>> getActivity() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/activity'), headers: await _headers());
      if (res.statusCode != 200) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } catch (_) { return []; }
  }

  Future<void> clearActivity() async {
    try {
      await http.delete(Uri.parse('$baseUrl/activity'), headers: await _headers());
    } catch (_) {}
  }
}