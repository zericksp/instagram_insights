// lib/providers/auth_provider.dart (VERSÃO ALTERNATIVA)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  // ✅ Verificar se usuário está logado (USANDO MÉTODOS ESTÁTICOS)
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // verifica se esta logado no SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (!_isLoggedIn) {
        // Usar método estático simples primeiro
        AuthService _authService = AuthService();
        _isLoggedIn = await _authService.isLoggedIn();
      }

      if (_isLoggedIn) {
        // Tentar obter dados do usuário
        final userData = await AuthService.getUserData();
        if (userData != null) {
          _user = UserModel.fromJson(userData);
        } else {
          // Se não há dados locais, fazer logout
          _isLoggedIn = false;
          await AuthService.logout();
        }
      }
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Login (USANDO MÉTODO DE INSTÂNCIA)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _authService.login(email, password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (response.success && response.user != null) {
        _user = response.user;
        _isLoggedIn = true;
        _isLoading = false;
        await prefs.setBool('isLoggedIn', true);
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Erro no login';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Registro (USANDO MÉTODO DE INSTÂNCIA)
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(name, email, password);

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Erro no registro';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Conectar Instagram (USANDO MÉTODO DE INSTÂNCIA)
  Future<bool> connectInstagram(String instagramCode) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.connectInstagram('', instagramCode);

      if (response.success && response.user != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Erro ao conectar Instagram';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Logout (USANDO MÉTODO ESTÁTICO)
  Future<void> logout() async {
    await AuthService.logout(); // Usar método estático
    _user = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  // ✅ Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ✅ Atualizar dados do usuário
  Future<void> refreshUserData() async {
    if (!_isLoggedIn) return;

    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
