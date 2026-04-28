class Artist {
  final String id, name;
  final int monthlyListeners;
  Artist({required this.id, required this.name, required this.monthlyListeners});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'monthlyListeners': monthlyListeners};
  factory Artist.fromJson(Map<String, dynamic> j) => Artist(id: j['id'], name: j['name'], monthlyListeners: j['monthlyListeners'] ?? 0);
}

class Album {
  final String id, title;
  final Artist artist;
  final int releaseYear;
  Album({required this.id, required this.title, required this.artist, required this.releaseYear});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'artist': artist.toJson(), 'releaseYear': releaseYear};
  factory Album.fromJson(Map<String, dynamic> j) => Album(id: j['id'], title: j['title'], artist: Artist.fromJson(j['artist']), releaseYear: j['releaseYear']);
}

class Song {
  final String id, title, audioUrl;
  final Artist artist;
  final Album album;
  Song({required this.id, required this.title, required this.artist, required this.album, required this.audioUrl});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'artist': artist.toJson(), 'album': album.toJson(), 'audioUrl': audioUrl};
  factory Song.fromJson(Map<String, dynamic> j) => Song(id: j['id'], title: j['title'], artist: Artist.fromJson(j['artist']), album: Album.fromJson(j['album']), audioUrl: j['audioUrl'] ?? '');
}

class Playlist {
  final String id, title, description;
  final List<Song> songs;
  String syncStatus;
  Playlist({required this.id, required this.title, required this.description, required this.songs, this.syncStatus = 'pending'});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description, 'syncStatus': syncStatus, 'songs': songs.map((s) => s.toJson()).toList()};
  factory Playlist.fromJson(Map<String, dynamic> j) => Playlist(id: j['id'], title: j['title'], description: j['description'], syncStatus: j['syncStatus'] ?? 'synced', songs: (j['songs'] as List).map((s) => Song.fromJson(s)).toList());
}

class UserProfile {
  final String username;
  final int followersCount;
  final bool isPremium;
  final double listeningHours;
  UserProfile({required this.username, required this.followersCount, required this.isPremium, required this.listeningHours});
}