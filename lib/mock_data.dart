import 'models.dart';

final List<Song> mockSongs = [
  Song(
    id: '1',
    title: 'Bohemian Rhapsody',
    artist: 'Queen',
    durationInSeconds: 354,
    isFavorite: true,
    releaseDate: DateTime(1975, 10, 31),
  ),
  Song(
    id: '2',
    title: 'Blinding Lights',
    artist: 'The Weeknd',
    durationInSeconds: 200,
    isFavorite: false,
    releaseDate: DateTime(2019, 11, 29),
  ),
  Song(
    id: '3',
    title: 'Space Oddity',
    artist: 'David Bowie',
    durationInSeconds: 315,
    isFavorite: true,
    releaseDate: DateTime(1969, 7, 11),
  ),
];

final UserProfile currentUser = UserProfile(
  username: 'MusicLover_UA',
  followersCount: 142,
  isPremium: true,
  listeningHours: 1245.5,
);