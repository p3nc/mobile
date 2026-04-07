class Song {
  final String id;
  final String title;
  final String artist;
  final int durationInSeconds;
  final bool isFavorite;
  final DateTime releaseDate;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.durationInSeconds,
    required this.isFavorite,
    required this.releaseDate,
  });
}

class UserProfile {
  final String username;
  final int followersCount;
  final bool isPremium;
  final double listeningHours;

  UserProfile({
    required this.username,
    required this.followersCount,
    required this.isPremium,
    required this.listeningHours,
  });
}