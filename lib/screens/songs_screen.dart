import 'package:flutter/material.dart';
import '../models.dart';
import '../mock_data.dart';
import '../repository.dart';
import 'song_detail_screen.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});
  @override State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final Repository _repository = Repository();
  String _searchQuery = '';
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await _repository.getFavorites();
    setState(() => _favoriteIds = favs);
  }

  Future<void> _toggleFavorite(Song song) async {
    await _repository.toggleFavorite(song.id, title: song.title, artist: song.artist.name);
    _loadFavorites();
  }

  void _showAddToPlaylistMenu(Song song) async {
    final playlists = await _repository.getPlaylists();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Додати "${song.title}" у плейлист',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: playlists.isEmpty
                  ? const Center(child: Text('Немає плейлистів'))
                  : ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  final isAdded = playlist.songs.any((s) => s.id == song.id);
                  return ListTile(
                    title: Text(playlist.title),
                    trailing: isAdded ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: isAdded ? null : () async {
                      playlist.songs.add(song);
                      await _repository.syncPlaylist(playlist);
                      if (mounted) Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSongs = allAvailableSongs
        .where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Всі пісні')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Пошук...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];
                final isFav = _favoriteIds.contains(song.id);
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(song.title),
                  subtitle: Text(song.artist.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.green : Colors.grey),
                        onPressed: () => _toggleFavorite(song),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showAddToPlaylistMenu(song),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SongDetailScreen(songs: filteredSongs, initialIndex: index))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}