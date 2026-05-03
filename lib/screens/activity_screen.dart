import 'package:flutter/material.dart';
import '../repository.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});
  @override State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final Repository _repository = Repository();
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    final data = await _repository.getActivity();
    setState(() { _activities = data; _isLoading = false; });
  }

  Future<void> _clearActivity() async {
    await _repository.clearActivity();
    _loadActivity();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'auth': return Icons.login;
      case 'playlist': return Icons.library_music;
      case 'favorite': return Icons.favorite;
      case 'security': return Icons.security;
      default: return Icons.info;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'auth': return Colors.blue;
      case 'playlist': return Colors.orange;
      case 'favorite': return Colors.red;
      case 'security': return Colors.green;
      default: return Colors.grey;
    }
  }

  // Сервер повертає createdAt (camelCase)
  String _formatDate(Map<String, dynamic> a) {
    final raw = a['createdAt'] ?? a['created_at'] ?? '';
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Активність'),
        actions: [
          if (_activities.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Очистити',
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Очистити історію?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Ні')),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); _clearActivity(); },
                      child: const Text('Так'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
          ? const Center(child: Text('Немає активності'))
          : RefreshIndicator(
        onRefresh: _loadActivity,
        child: ListView.builder(
          itemCount: _activities.length,
          itemBuilder: (context, index) {
            final a = _activities[index];
            final type = a['type'] ?? '';
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _colorForType(type).withOpacity(0.2),
                child: Icon(_iconForType(type),
                    color: _colorForType(type), size: 20),
              ),
              title: Text(a['description'] ?? ''),
              subtitle: Text(_formatDate(a)),
            );
          },
        ),
      ),
    );
  }
}