import 'package:flutter/material.dart';
import '../models.dart';
import '../mock_data.dart';
import '../repository.dart';
import 'song_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Repository _repository = Repository();
  List<Song> _favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favIds = await _repository.getFavorites();
    setState(() {
      _favoriteSongs = allAvailableSongs.where((s) => favIds.contains(s.id)).toList();
    });
  }

  Future<void> _removeFavorite(Song song) async {
    await _repository.toggleFavorite(song.id, title: song.title, artist: song.artist.name);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Улюблені пісні')),
      body: _favoriteSongs.isEmpty
          ? const Center(child: Text('У вас ще немає улюблених пісень'))
          : ListView.builder(
        itemCount: _favoriteSongs.length,
        itemBuilder: (context, index) {
          final song = _favoriteSongs[index];
          return Dismissible(
            key: Key(song.id),
            background: Container(color: Colors.red, alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) => _removeFavorite(song),
            child: ListTile(
              leading: const Icon(Icons.music_note, color: Colors.green),
              title: Text(song.title),
              subtitle: Text(song.artist.name),
              trailing: const Icon(Icons.play_arrow),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SongDetailScreen(songs: _favoriteSongs, initialIndex: index))),
            ),
          );
        },
      ),
    );
  }
}