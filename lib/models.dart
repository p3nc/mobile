import 'dart:convert';

class Artist {
  final String id;
  final String name;
  final int monthlyListeners;

  Artist({required this.id, required this.name, required this.monthlyListeners});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'monthlyListeners': monthlyListeners};
  factory Artist.fromJson(Map<String, dynamic> json) => Artist(id: json['id'], name: json['name'], monthlyListeners: json['monthlyListeners']);
}

class Album {
  final String id;
  final String title;
  final Artist artist;
  final int releaseYear;

  Album({required this.id, required this.title, required this.artist, required this.releaseYear});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'artist': artist.toJson(), 'releaseYear': releaseYear};
  factory Album.fromJson(Map<String, dynamic> json) => Album(id: json['id'], title: json['title'], artist: Artist.fromJson(json['artist']), releaseYear: json['releaseYear']);
}

class Song {
  final String id;
  final String title;
  final Artist artist;
  final Album album;
  final int durationInSeconds;
  final bool isFavorite;

  Song({required this.id, required this.title, required this.artist, required this.album, required this.durationInSeconds, required this.isFavorite});

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'artist': artist.toJson(), 'album': album.toJson(), 'durationInSeconds': durationInSeconds, 'isFavorite': isFavorite
  };
  factory Song.fromJson(Map<String, dynamic> json) => Song(
      id: json['id'], title: json['title'], artist: Artist.fromJson(json['artist']), album: Album.fromJson(json['album']), durationInSeconds: json['durationInSeconds'], isFavorite: json['isFavorite']
  );
}

class Playlist {
  final String id;
  final String title;
  final String description;
  final List<Song> songs;
  String syncStatus;

  Playlist({required this.id, required this.title, required this.description, required this.songs, this.syncStatus = 'pending'});

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description, 'syncStatus': syncStatus,
    'songs': songs.map((s) => s.toJson()).toList(),
  };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    id: json['id'], title: json['title'], description: json['description'], syncStatus: json['syncStatus'] ?? 'synced',
    songs: (json['songs'] as List).map((s) => Song.fromJson(s)).toList(),
  );
}

class UserProfile {
  final String username;
  final int followersCount;
  final bool isPremium;
  final double listeningHours;

  UserProfile({required this.username, required this.followersCount, required this.isPremium, required this.listeningHours});
}