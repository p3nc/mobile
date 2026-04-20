import 'models.dart';
import 'api_service.dart';
import 'local_storage.dart';

class Repository {
  final LocalStorage _storage = LocalStorage();
  final ApiService _api = ApiService();

  Future<List<Playlist>> getPlaylists() async {
    List<Playlist> localData = await _storage.getAllPlaylists();
    if (localData.isEmpty) {
      localData = await _api.fetchPlaylists();
      await _storage.savePlaylists(localData);
    }
    return localData;
  }

  Future<void> addPlaylist(Playlist playlist) async {
    final playlists = await _storage.getAllPlaylists();
    playlists.add(playlist);
    await _storage.savePlaylists(playlists);

    bool success = await _api.syncPlaylist(playlist);
    if (success) {
      playlist.syncStatus = 'synced';
      await _storage.updatePlaylist(playlist);
    }
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    playlist.syncStatus = 'pending';
    await _storage.updatePlaylist(playlist);

    bool success = await _api.syncPlaylist(playlist);
    if (success) {
      playlist.syncStatus = 'synced';
      await _storage.updatePlaylist(playlist);
    }
  }

  Future<void> removePlaylist(String id) async {
    await _storage.deletePlaylist(id);
    await _api.deletePlaylist(id);
  }

  Future<List<String>> getFavorites() async {
    return await _storage.getFavoriteSongIds();
  }

  Future<void> toggleFavorite(String songId) async {
    final favs = await _storage.getFavoriteSongIds();
    if (favs.contains(songId)) {
      favs.remove(songId);
    } else {
      favs.add(songId);
    }
    await _storage.saveFavoriteSongIds(favs);
  }
}