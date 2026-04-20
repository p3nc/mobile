import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import 'song_detail_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late Playlist _playlist;
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist;
  }

  Future<void> _removeSong(String songId) async {
    setState(() => _playlist.songs.removeWhere((s) => s.id == songId));
    await _repository.updatePlaylist(_playlist);
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: _playlist.title);
    final descController = TextEditingController(text: _playlist.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редагувати плейлист'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Назва'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Опис'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Скасувати')),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _playlist = Playlist(
                    id: _playlist.id,
                    title: titleController.text,
                    description: descController.text,
                    songs: _playlist.songs,
                    syncStatus: 'pending',
                  );
                });
                await _repository.updatePlaylist(_playlist);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Зберегти'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_playlist.title),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_playlist.description, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ),
          const Divider(),
          Expanded(
            child: _playlist.songs.isEmpty
                ? const Center(child: Text('Плейлист порожній. Додайте пісні з вкладки "Пісні".', textAlign: TextAlign.center))
                : ListView.builder(
              itemCount: _playlist.songs.length,
              itemBuilder: (context, index) {
                final song = _playlist.songs[index];
                return Dismissible(
                  key: Key(song.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => _removeSong(song.id),
                  child: ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(song.title),
                    subtitle: Text(song.artist.name),
                    trailing: const Icon(Icons.play_arrow, color: Colors.green),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SongDetailScreen(song: song))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}