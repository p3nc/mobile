import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'auth_service.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000/api';
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<List<Playlist>> fetchPlaylists() async {
    final res = await http.get(Uri.parse('$baseUrl/playlists'), headers: await _headers());
    return res.statusCode == 200 ? (jsonDecode(res.body) as List).map((j) => Playlist.fromJson(j)).toList() : [];
  }

  Future<bool> syncPlaylist(Playlist p) async {
    final res = await http.post(Uri.parse('$baseUrl/playlists'), headers: await _headers(), body: jsonEncode(p.toJson()));
    return res.statusCode <= 201;
  }

  Future<bool> deletePlaylist(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/playlists/$id'), headers: await _headers());
    return res.statusCode == 200;
  }

  Future<List<String>> fetchFavorites() async {
    final res = await http.get(Uri.parse('$baseUrl/favorites'), headers: await _headers());
    return res.statusCode == 200 ? List<String>.from(jsonDecode(res.body)) : [];
  }

  Future<void> toggleFavorite(String songId) async {
    await http.post(Uri.parse('$baseUrl/favorites/toggle'), headers: await _headers(), body: jsonEncode({'songId': songId}));
  }
}