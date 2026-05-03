import 'package:flutter/material.dart';
import '../auth_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  String _username = '';
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final username = await _auth.getUsername();
    final biometricAvailable = await _auth.isBiometricAvailable();
    final biometricEnabled = await _auth.hasBiometricSession();
    setState(() {
      _username = username;
      _biometricAvailable = biometricAvailable;
      _biometricEnabled = biometricEnabled;
    });
  }

  Future<void> _toggleBiometric() async {
    if (_biometricEnabled) {
      await _auth.disableBiometric();
      setState(() => _biometricEnabled = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Біометрію вимкнено')),
      );
    } else {
      final ok = await _auth.enableBiometric();
      setState(() => _biometricEnabled = ok);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Біометрію увімкнено!' : 'Не вдалось увімкнути'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(_username,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 32),
          const Divider(),
          if (_biometricAvailable)
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint, color: Colors.green),
              title: const Text('Біометрична авторизація'),
              subtitle: Text(_biometricEnabled ? 'Увімкнено' : 'Вимкнено'),
              value: _biometricEnabled,
              onChanged: (_) => _toggleBiometric(),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Вийти з акаунта',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _auth.logout();
              if (mounted) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()));
              }
            },
          ),
        ],
      ),
    );
  }
}