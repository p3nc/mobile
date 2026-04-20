import 'package:flutter/material.dart';
import '../models.dart';

class SongDetailScreen extends StatelessWidget {
  final Song song;

  const SongDetailScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(song.album.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.album, size: 200, color: Colors.grey),
            const SizedBox(height: 30),
            Text(song.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(song.artist.name, style: const TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Альбом: ${song.album.title} • ${song.album.releaseYear}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.skip_previous, size: 50),
                SizedBox(width: 20),
                Icon(Icons.play_circle_filled, size: 80, color: Colors.green),
                SizedBox(width: 20),
                Icon(Icons.skip_next, size: 50),
              ],
            )
          ],
        ),
      ),
    );
  }
}