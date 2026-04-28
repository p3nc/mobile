import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<bool> register(String email, String password, String username) async {
    final res = await http.post(Uri.parse('$baseUrl/register'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'password': password, 'username': username}));
    if (res.statusCode == 201) {
      await _saveData(jsonDecode(res.body)['token'], username);
      return true;
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/login'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'password': password}));
    if (res.statusCode == 200) {
      await _saveData(jsonDecode(res.body)['token'], jsonDecode(res.body)['username']);
      return true;
    }
    return false;
  }

  Future<void> _saveData(String token, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('username', username);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String?> getToken() async => (await SharedPreferences.getInstance()).getString('jwt_token');
  Future<String> getUsername() async => (await SharedPreferences.getInstance()).getString('username') ?? 'User';
}