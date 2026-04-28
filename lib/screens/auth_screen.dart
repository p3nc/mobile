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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    bool success = _isLogin ? await _auth.login(_email, _password) : await _auth.register(_email, _password, _username);
    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Помилка авторизації')));
    }
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
              if (!_isLogin) TextFormField(decoration: const InputDecoration(labelText: 'Ім\'я'), validator: (v) => v!.length < 3 ? 'Мін 3 символи' : null, onSaved: (v) => _username = v!),
              TextFormField(decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => !v!.contains('@') ? 'Помилка email' : null, onSaved: (v) => _email = v!),
              TextFormField(decoration: const InputDecoration(labelText: 'Пароль'), obscureText: true, validator: (v) {
                if (v == null || v.length < 8) return 'Мінімум 8 символів';
                if (!v.contains(RegExp(r'[A-Z]'))) return 'Додайте велику літеру';
                if (!v.contains(RegExp(r'[0-9]'))) return 'Додайте цифру';
                return null;
              }, onSaved: (v) => _password = v!),
              const SizedBox(height: 20),
              _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _submit, child: Text(_isLogin ? 'Увійти' : 'Зареєструватись')),
              TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? 'Створити акаунт' : 'Вже є акаунт? Увійти'))
            ],
          ),
        ),
      ),
    );
  }
}