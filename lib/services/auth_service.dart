// ========================================
// lib/services/auth_service.dart
// ========================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://seudominio.com/api';

  // Cache de autenticação
  static String? _cachedToken;
  static Map<String, dynamic>? _cachedUser;
  static String? _cachedCnpj;

  /// Fazer login com email e senha
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Salvar dados do usuário logado
          await _saveAuthData(
            data['token'],
            data['user'],
            data['company'],
          );

          return {
            'success': true,
            'user': data['user'],
            'company': data['company'],
            'token': data['token'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Erro desconhecido',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Erro de conexão: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de rede: $e',
      };
    }
  }

  /// Verificar se usuário está logado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final expiry = prefs.getString('auth_expiry');

    if (token == null || expiry == null) {
      return false;
    }

    // Verificar se token não expirou
    final expiryDate = DateTime.parse(expiry);
    if (DateTime.now().isAfter(expiryDate)) {
      await logout();
      return false;
    }

    // Carregar dados em cache
    _cachedToken = token;
    _cachedUser = json.decode(prefs.getString('auth_user') ?? '{}');
    _cachedCnpj = prefs.getString('company_cnpj');

    return true;
  }

  /// Obter dados do usuário logado
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_cachedUser != null) {
      return _cachedUser;
    }

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('auth_user');

    if (userJson != null) {
      _cachedUser = json.decode(userJson);
      return _cachedUser;
    }

    return null;
  }

  /// Obter CNPJ da empresa do usuário logado
  static Future<String?> getCompanyCnpj() async {
    if (_cachedCnpj != null) {
      return _cachedCnpj;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedCnpj = prefs.getString('company_cnpj');

    return _cachedCnpj;
  }

  /// Obter token de autenticação
  static Future<String?> getAuthToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('auth_token');

    return _cachedToken;
  }

  /// Fazer logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    await prefs.remove('auth_expiry');
    await prefs.remove('company_cnpj');
    await prefs.remove('company_data');

    // Limpar cache
    _cachedToken = null;
    _cachedUser = null;
    _cachedCnpj = null;
  }

  /// Salvar dados de autenticação
  static Future<void> _saveAuthData(
    String token,
    Map<String, dynamic> user,
    Map<String, dynamic> company,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Token expira em 7 dias
    final expiry = DateTime.now().add(const Duration(days: 7));

    await prefs.setString('auth_token', token);
    await prefs.setString('auth_user', json.encode(user));
    await prefs.setString('auth_expiry', expiry.toIso8601String());
    await prefs.setString('company_cnpj', company['cmp_cnpj']);
    await prefs.setString('company_data', json.encode(company));

    // Atualizar cache
    _cachedToken = token;
    _cachedUser = user;
    _cachedCnpj = company['cmp_cnpj'];
  }

  /// Validar token no servidor
  static Future<bool> validateToken() async {
    try {
      final token = await getAuthToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/validate.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['valid'] == true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
