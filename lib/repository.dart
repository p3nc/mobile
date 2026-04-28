import 'models.dart';
import 'api_service.dart';
import 'local_storage.dart';

class Repository {
  final LocalStorage _storage = LocalStorage();
  final ApiService _api = ApiService();

  Future<List<Playlist>> getPlaylists() async {
    List<Playlist> data = await _api.fetchPlaylists();
    await _storage.savePlaylists(data);
    return data;
  }

  Future<void> addPlaylist(Playlist playlist) async {
    final playlists = await _storage.getAllPlaylists();
    playlists.add(playlist);
    await _storage.savePlaylists(playlists);
    await syncPlaylist(playlist);
  }

  Future<void> syncPlaylist(Playlist p) async {
    p.syncStatus = 'pending';
    await _storage.updatePlaylist(p);
    if (await _api.syncPlaylist(p)) {
      p.syncStatus = 'synced';
      await _storage.updatePlaylist(p);
    }
  }

  Future<void> removePlaylist(String id) async {
    await _storage.deletePlaylist(id);
    await _api.deletePlaylist(id);
  }

  Future<List<String>> getFavorites() async {
    final favs = await _api.fetchFavorites();
    await _storage.saveFavoriteSongIds(favs);
    return favs;
  }

  Future<void> toggleFavorite(String songId) async {
    final favs = await _storage.getFavoriteSongIds();
    if (favs.contains(songId)) favs.remove(songId); else favs.add(songId);
    await _storage.saveFavoriteSongIds(favs);
    await _api.toggleFavorite(songId);
  }
}