import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../local_storage.dart';
import '../mock_data.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  String _username = '';

  @override
  void initState() {
    super.initState();
    _auth.getUsername().then((u) => setState(() => _username = u));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            Text(_username, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(currentUser.isPremium ? 'Premium Account' : 'Free Account', style: TextStyle(color: Colors.amber[700])),
            const Divider(height: 40, indent: 50, endIndent: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [Text(currentUser.followersCount.toString(), style: const TextStyle(fontSize: 20)), const Text('Підписники', style: TextStyle(color: Colors.grey))]),
                Column(children: [Text(currentUser.listeningHours.toString(), style: const TextStyle(fontSize: 20)), const Text('Годин', style: TextStyle(color: Colors.grey))]),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await LocalStorage().clearAll();
                await _auth.logout();
                if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
              },
              child: const Text('Вийти з акаунта'),
            )
          ],
        ),
      ),
    );
  }
}