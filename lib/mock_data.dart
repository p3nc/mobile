import 'models.dart';

final Artist ledZeppelin = Artist(id: 'a1', name: 'Led Zeppelin', monthlyListeners: 17000000);
final Artist pinkFloyd = Artist(id: 'a2', name: 'Pink Floyd', monthlyListeners: 18000000);
final Artist theBeatles = Artist(id: 'a3', name: 'The Beatles', monthlyListeners: 32000000);
final Artist acdc = Artist(id: 'a4', name: 'AC/DC', monthlyListeners: 28000000);
final Artist deepPurple = Artist(id: 'a5', name: 'Deep Purple', monthlyListeners: 8000000);

final Album ledZeppelinIV = Album(id: 'al1', title: 'Led Zeppelin IV', artist: ledZeppelin, releaseYear: 1971);
final Album darkSide = Album(id: 'al2', title: 'The Dark Side of the Moon', artist: pinkFloyd, releaseYear: 1973);
final Album abbeyRoad = Album(id: 'al3', title: 'Abbey Road', artist: theBeatles, releaseYear: 1969);
final Album backInBlack = Album(id: 'al4', title: 'Back in Black', artist: acdc, releaseYear: 1980);
final Album machineHead = Album(id: 'al5', title: 'Machine Head', artist: deepPurple, releaseYear: 1972);

final Song song1 = Song(id: 's1', title: 'Stairway to Heaven', artist: ledZeppelin, album: ledZeppelinIV, audioUrl: 'http://10.0.2.2:3000/music/track1.mp3');
final Song song2 = Song(id: 's2', title: 'Money', artist: pinkFloyd, album: darkSide, audioUrl: 'http://10.0.2.2:3000/music/track2.mp3');
final Song song3 = Song(id: 's3', title: 'Come Together', artist: theBeatles, album: abbeyRoad, audioUrl: 'http://10.0.2.2:3000/music/track3.mp3');
final Song song4 = Song(id: 's4', title: 'Back in Black', artist: acdc, album: backInBlack, audioUrl: 'http://10.0.2.2:3000/music/track4.mp3');
final Song song5 = Song(id: 's5', title: 'Smoke on the Water', artist: deepPurple, album: machineHead, audioUrl: 'http://10.0.2.2:3000/music/track5.mp3');

final List<Song> allAvailableSongs = [song1, song2, song3, song4, song5];

final UserProfile currentUser = UserProfile(
  username: 'RockFan_80',
  followersCount: 256,
  isPremium: true,
  listeningHours: 450.8,
);