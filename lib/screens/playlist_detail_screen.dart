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
  final Repository _rep = Repository();

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist;
  }

  Future<void> _removeSong(String songId) async {
    setState(() => _playlist.songs.removeWhere((s) => s.id == songId));
    await _rep.syncPlaylist(_playlist);
  }

  void _edit() {
    final t = TextEditingController(text: _playlist.title);
    final d = TextEditingController(text: _playlist.description);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Редагувати'),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: t, decoration: const InputDecoration(labelText: 'Назва')),
                TextField(controller: d, decoration: const InputDecoration(labelText: 'Опис')),
              ]
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Відміна')),
            TextButton(
                onPressed: () async {
                  setState(() {
                    _playlist = Playlist(
                        id: _playlist.id,
                        title: t.text,
                        description: d.text,
                        songs: _playlist.songs,
                        syncStatus: 'pending'
                    );
                  });
                  Navigator.pop(context);
                  await _rep.syncPlaylist(_playlist);
                },
                child: const Text('Зберегти')
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_playlist.title),
          actions: [IconButton(icon: const Icon(Icons.edit), onPressed: _edit)]
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_playlist.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 16))
            ),
            const Divider(),
            Expanded(
                child: ListView.builder(
                  itemCount: _playlist.songs.length,
                  itemBuilder: (context, index) {
                    final s = _playlist.songs[index];
                    return Dismissible(
                      key: Key(s.id),
                      background: Container(color: Colors.red),
                      onDismissed: (_) => _removeSong(s.id),
                      child: ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(s.title),
                        subtitle: Text(s.artist.name),
                        trailing: const Icon(Icons.play_arrow),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SongDetailScreen(
                                  songs: _playlist.songs,
                                  initialIndex: index,
                                )
                            )
                        ),
                      ),
                    );
                  },
                )
            ),
          ]
      ),
    );
  }
}