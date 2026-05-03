import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.0.188:3000/api';
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ══ РЕЄСТРАЦІЯ ══

  Future<bool> register(String username, String password, [String? displayName]) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode != 201) return false;
      final data = jsonDecode(res.body);
      await _saveData(data['token'], data['username']);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ══ ВХІД ══

  Future<bool> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body);
      await _saveData(data['token'], data['username']);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveData(String token, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('username', username);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.delete(key: 'biometric_username');
    await _secureStorage.delete(key: 'biometric_token');
  }

  Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString('jwt_token');

  Future<String> getUsername() async =>
      (await SharedPreferences.getInstance()).getString('username') ?? 'User';

  // ══ БІОМЕТРІЯ ══

  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } catch (_) { return false; }
  }

  Future<bool> hasBiometricSession() async {
    final username = await _secureStorage.read(key: 'biometric_username');
    if (username == null) return false;
    return await _secureStorage.read(key: 'biometric_token') != null;
  }

  Future<bool> enableBiometric() async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Підтвердіть для увімкнення біометрії',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (!ok) return false;
      final token = await getToken();
      final username = await getUsername();
      if (token == null) return false;
      await _secureStorage.write(key: 'biometric_token', value: token);
      await _secureStorage.write(key: 'biometric_username', value: username);
      return true;
    } catch (_) { return false; }
  }

  Future<bool> loginWithBiometrics() async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Підтвердіть вашу особу для входу',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (!ok) return false;
      final token = await _secureStorage.read(key: 'biometric_token');
      final username = await _secureStorage.read(key: 'biometric_username');
      if (token == null || username == null) return false;
      await _saveData(token, username);
      return true;
    } catch (_) { return false; }
  }

  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: 'biometric_token');
    await _secureStorage.delete(key: 'biometric_username');
  }
}