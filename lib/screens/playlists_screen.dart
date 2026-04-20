import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import 'playlist_detail_screen.dart';
import 'favorites_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final Repository _repository = Repository();
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _repository.getPlaylists();
    setState(() {
      _playlists = data;
      _isLoading = false;
    });
  }

  Future<void> _addNewPlaylist() async {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Новий Плейлист ${_playlists.length + 1}',
      description: 'Мій новий плейлист',
      songs: [],
      syncStatus: 'pending',
    );
    setState(() => _playlists.add(newPlaylist));
    await _repository.addPlaylist(newPlaylist);
  }

  Future<void> _deletePlaylist(String id) async {
    setState(() => _playlists.removeWhere((p) => p.id == id));
    await _repository.removePlaylist(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мої Плейлисти')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.green, size: 40),
            title: const Text('Улюблені пісні', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Ваша колекція лайкнутих треків'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            ),
          ),
          const Divider(),
          ..._playlists.map((playlist) => Dismissible(
            key: Key(playlist.id),
            background: Container(color: Colors.red, alignment: Alignment.centerRight, child: const Icon(Icons.delete)),
            onDismissed: (direction) => _deletePlaylist(playlist.id),
            child: Card(
              child: ListTile(
                leading: Icon(
                  playlist.syncStatus == 'synced' ? Icons.cloud_done : Icons.cloud_upload,
                  color: playlist.syncStatus == 'synced' ? Colors.green : Colors.orange,
                ),
                title: Text(playlist.title),
                subtitle: Text('${playlist.songs.length} треків'),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlaylistDetailScreen(playlist: playlist)),
                  );
                  _loadData();
                },
              ),
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPlaylist,
        child: const Icon(Icons.add),
      ),
    );
  }
}