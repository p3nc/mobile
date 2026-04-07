import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models.dart';
import 'song_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мій Плейліст')),
      body: ListView.builder(
        itemCount: mockSongs.length,
        itemBuilder: (context, index) {
          final Song song = mockSongs[index];
          return ListTile(
            leading: const Icon(Icons.music_note, size: 40),
            title: Text(song.title),
            subtitle: Text(song.artist),
            trailing: Icon(
              song.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: song.isFavorite ? Colors.green : Colors.grey,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongDetailScreen(song: song),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
