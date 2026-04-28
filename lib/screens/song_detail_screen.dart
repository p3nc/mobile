import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models.dart';

class SongDetailScreen extends StatefulWidget {
  final List<Song> songs;
  final int initialIndex;

  const SongDetailScreen({super.key, required this.songs, required this.initialIndex});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  final _p = AudioPlayer();
  bool _isP = false;
  Duration _dur = Duration.zero;
  Duration _pos = Duration.zero;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadSong();

    _p.onPlayerStateChanged.listen((s) => setState(() => _isP = s == PlayerState.playing));
    _p.onDurationChanged.listen((d) => setState(() => _dur = d));
    _p.onPositionChanged.listen((p) => setState(() => _pos = p));

    // Автоматичне перемикання на наступну пісню після завершення
    _p.onPlayerComplete.listen((event) => _next());
  }

  void _loadSong() async {
    await _p.stop();
    await _p.setSourceUrl(widget.songs[_currentIndex].audioUrl);
    _p.resume();
  }

  void _next() {
    if (_currentIndex < widget.songs.length - 1) {
      setState(() => _currentIndex++);
      _loadSong();
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadSong();
    }
  }

  @override
  void dispose() {
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.songs[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(song.album.title), centerTitle: true),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note, size: 200, color: Colors.green),
              const SizedBox(height: 30),
              Text(song.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text(song.artist.name, style: const TextStyle(fontSize: 18, color: Colors.grey)),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Text(_reg(_pos)),
                    Expanded(
                        child: Slider(
                            min: 0,
                            max: _dur.inSeconds.toDouble() > 0 ? _dur.inSeconds.toDouble() : 1.0,
                            value: _pos.inSeconds.toDouble(),
                            onChanged: (v) => _p.seek(Duration(seconds: v.toInt()))
                        )
                    ),
                    Text(_reg(_dur)),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 50,
                      onPressed: _currentIndex > 0 ? _previous : null
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                      icon: Icon(_isP ? Icons.pause_circle_filled : Icons.play_circle_filled),
                      iconSize: 80,
                      color: Colors.green,
                      onPressed: () => _isP ? _p.pause() : _p.resume()
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 50,
                      onPressed: _currentIndex < widget.songs.length - 1 ? _next : null
                  ),
                ],
              )
            ],
          )
      ),
    );
  }

  String _reg(Duration d) => "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
}