import 'package:flutter/material.dart';
import '../socket_manager.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});
  @override State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final SocketManager _socketManager = SocketManager();
  final List<String> _activities = [];
  String _connectionState = SocketState.disconnected.name;

  @override
  void initState() {
    super.initState();
    _socketManager.connect('ws://10.0.2.2:3000');
    _socketManager.stream.listen((data) {
      if (!mounted) return;
      setState(() {
        if (data['type'] == 'state_change') _connectionState = data['state'];
        else if (data['type'] == 'friend_activity') _activities.insert(0, '${data['friend']} слухає ${data['songTitle']}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Активність (${_connectionState.toUpperCase()})')),
      body: ListView.builder(
        itemCount: _activities.length,
        itemBuilder: (context, index) => ListTile(title: Text(_activities[index]), leading: const Icon(Icons.person)),
      ),
    );
  }
}