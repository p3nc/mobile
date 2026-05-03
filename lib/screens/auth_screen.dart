import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  bool _isLogin = true;
  String _email = '', _password = '', _username = '';
  bool _isLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _auth.isBiometricAvailable();
    final hasSession = await _auth.hasBiometricSession();
    setState(() => _biometricAvailable = available);
    if (hasSession) _loginWithBiometrics();
  }

  Future<void> _loginWithBiometrics() async {
    setState(() => _isLoading = true);
    final ok = await _auth.loginWithBiometrics();
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Біометрична авторизація не вдалась')),
      );
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    bool success = _isLogin
        ? await _auth.login(_email, _password)
        : await _auth.register(_email, _password, _username);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      if (_isLogin && _biometricAvailable) {
        _showEnableBiometricDialog();
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Помилка авторизації')),
      );
    }
  }

  void _showEnableBiometricDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Увімкнути біометрію?'),
        content: const Text('Бажаєте входити через відбиток пальця або Face ID?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
            },
            child: const Text('Пізніше'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final enabled = await _auth.enableBiometric();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(enabled ? 'Біометрію увімкнено!' : 'Не вдалось'),
                backgroundColor: enabled ? Colors.green : Colors.red,
              ));
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
            },
            child: const Text('Увімкнути'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Вхід' : 'Реєстрація')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isLogin)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ім\'я'),
                  validator: (v) => v!.length < 3 ? 'Мін 3 символи' : null,
                  onSaved: (v) => _username = v!,
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Логін'),
                validator: (v) => v == null || v.isEmpty ? 'Введіть логін' : null,
                onSaved: (v) => _email = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length < 8) return 'Мінімум 8 символів';
                  if (!v.contains(RegExp(r'[A-Z]'))) return 'Додайте велику літеру';
                  if (!v.contains(RegExp(r'[0-9]'))) return 'Додайте цифру';
                  return null;
                },
                onSaved: (v) => _password = v!,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: Text(_isLogin ? 'Увійти' : 'Зареєструватись'),
                ),
                if (_isLogin && _biometricAvailable) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _loginWithBiometrics,
                    icon: const Icon(Icons.fingerprint, size: 28),
                    label: const Text('Увійти з біометрією'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ],
              ],
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'Створити акаунт' : 'Вже є акаунт? Увійти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}