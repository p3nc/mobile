import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models.dart';
import 'package:mobile/socket_manager.dart';

void main() {
  group('Models JSON & Logic Tests (1-10)', () {
    final artistJson = {'id': 'a1', 'name': 'Led Zeppelin', 'monthlyListeners': 17000000};
    final albumJson = {
      'id': 'al1',
      'title': 'Led Zeppelin IV',
      'releaseYear': 1971,
      'artist': artistJson
    };

    test('1. Artist: перевірка створення об\'єкта та monthlyListeners', () {
      final a = Artist.fromJson(artistJson);
      expect(a.name, 'Led Zeppelin');
      expect(a.monthlyListeners, 17000000);
    });

    test('2. Artist: перевірка серіалізації в JSON', () {
      final a = Artist(id: '1', name: 'Queen', monthlyListeners: 500);
      expect(a.toJson()['monthlyListeners'], 500);
    });

    test('3. Album: перевірка вкладеності об\'єктів при парсингу', () {
      final al = Album.fromJson(albumJson);
      expect(al.title, 'Led Zeppelin IV');
      expect(al.artist.name, 'Led Zeppelin');
    });

    test('4. Song: перевірка повної структури JSON', () {
      final sJson = {
        'id': 's1',
        'title': 'Stairway',
        'audioUrl': 'url',
        'artist': artistJson,
        'album': albumJson
      };
      final s = Song.fromJson(sJson);
      expect(s.title, 'Stairway');
      expect(s.audioUrl, 'url');
    });

    test('5. Playlist: перевірка статусу синхронізації за замовчуванням', () {
      final p = Playlist.fromJson({'id': '1', 'title': 'P', 'description': 'D', 'songs': []});
      expect(p.syncStatus, 'synced');
    });

    test('6. Playlist: перевірка початкового статусу pending', () {
      final p = Playlist(id: '1', title: 'T', description: 'D', songs: []);
      expect(p.syncStatus, 'pending');
    });

    test('7. Playlist: додавання пісні в список', () {
      final s = Song.fromJson({
        'id': '1', 'title': 'T', 'audioUrl': 'u',
        'artist': artistJson, 'album': albumJson
      });
      final p = Playlist(id: '1', title: 'T', description: 'D', songs: []);
      p.songs.add(s);
      expect(p.songs.length, 1);
    });

    test('8. Playlist: видалення пісні зі списку', () {
      final s = Song.fromJson({
        'id': '1', 'title': 'T', 'audioUrl': 'u',
        'artist': artistJson, 'album': albumJson
      });
      final p = Playlist(id: '1', title: 'T', description: 'D', songs: [s]);
      p.songs.removeWhere((i) => i.id == '1');
      expect(p.songs.length, 0);
    });

    test('9. UserProfile: перевірка збереження даних профілю', () {
      final u = UserProfile(username: 'Den', followersCount: 10, isPremium: true, listeningHours: 5.5);
      expect(u.username, 'Den');
      expect(u.isPremium, true);
    });

    test('10. Song: перевірка відповідності audioUrl', () {
      final s = Song(
          id: '1', title: 'S', audioUrl: 'test_url',
          artist: Artist(id: '1', name: 'A', monthlyListeners: 0),
          album: Album(id: '1', title: 'A', releaseYear: 2020, artist: Artist(id: '1', name: 'A', monthlyListeners: 0))
      );
      expect(s.audioUrl, 'test_url');
    });
  });

  group('SocketManager Real-time Tests (11-15)', () {
    late SocketManager socket;

    setUp(() {
      socket = SocketManager();
      socket.disconnect();
    });

    test('11. Socket: початковий стан має бути disconnected', () {
      expect(socket.state, SocketState.disconnected);
    });

    test('12. Socket: метод connect змінює стан на connecting', () {
      socket.connect('ws://test_url');
      expect(socket.state, SocketState.connecting);
    });

    test('13. Socket: метод disconnect коректно скидає стан', () {
      socket.connect('ws://test_url');
      socket.disconnect();
      expect(socket.state, SocketState.disconnected);
    });

    test('14. Socket: метод reconnect переводить у стан reconnecting', () {
      socket.reconnect('ws://test_url');
      expect(socket.state, SocketState.reconnecting);
    });

    test('15. Socket: перевірка Singleton (один і той же об\'єкт)', () {
      final s1 = SocketManager();
      final s2 = SocketManager();
      expect(identical(s1, s2), true);
    });
  });
}