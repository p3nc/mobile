import 'package:flutter/material.dart';
import '../mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60))),
            const SizedBox(height: 30),
            Text('Користувач: ${user.username}', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text('Підписників: ${user.followersCount}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Прослухано годин: ${user.listeningHours}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Chip(
              label: Text(user.isPremium ? 'Premium Plan' : 'Free Plan'),
              backgroundColor: user.isPremium ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}