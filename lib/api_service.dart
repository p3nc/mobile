import 'models.dart';
import 'mock_data.dart';

class ApiService {
  Future<List<Playlist>> fetchPlaylists() async {
    await Future.delayed(const Duration(seconds: 2));
    return initialPlaylists;
  }

  Future<bool> syncPlaylist(Playlist playlist) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> deletePlaylist(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}