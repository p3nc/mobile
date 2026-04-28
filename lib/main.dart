import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/songs_screen.dart';
import 'screens/playlists_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(const SpotifyCloneApp());

class SpotifyCloneApp extends StatelessWidget {
  const SpotifyCloneApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Spotify Clone', theme: ThemeData.dark(), home: const AuthWrapper(), debugShowCheckedModeBanner: false);
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    AuthService().getToken().then((token) {
      setState(() { _isAuthenticated = token != null; _isLoading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return _isAuthenticated ? const MainNavigationScreen() : const AuthScreen();
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [const SongsScreen(), const PlaylistsScreen(), const ActivityScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, type: BottomNavigationBarType.fixed, selectedItemColor: Colors.green,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Пісні'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Плейлисти'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Активність'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профіль'),
        ],
      ),
    );
  }
}