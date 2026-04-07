import 'package:flutter/material.dart';
import '../models.dart';

class SongDetailScreen extends StatelessWidget {
  final Song song;

  const SongDetailScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Зараз грає')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.album, size: 200, color: Colors.grey),
            const SizedBox(height: 30),
            Text(song.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(song.artist, style: const TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 20),
            Text('Тривалість: ${song.durationInSeconds} сек.'),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
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
