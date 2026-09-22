import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _user;
  String? _token;
  bool _loading = true;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get loading => _loading;

  AuthService() {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    await applySession(data);
  }

  Future<void> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
    String role = 'owner',
  }) async {
    final data = await _api.post('/auth/register', {
      'email': email,
      'phone': phone,
      'password': password,
      'full_name': fullName,
      'role': role,
    });
    await applySession(data);
  }

  Future<void> applySession(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    _token = data['token'] as String?;
    _user = Map<String, dynamic>.from(data['user'] as Map);
    await prefs.setString('token', _token!);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    _user = null;
    notifyListeners();
  }
}
