// ===== 2. SERVICES =====
// lib/services/auth_service.dart
// ========================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';

class AuthService {
  static const String baseUrl = 'https://tiven.com.br/instagram/api';
  // static const String baseUrl = 'http://10.0.2.2/tiven.com.br/instagram/api';

  // =======================================================================
  // MÉTODOS DE INSTÂNCIA (para usar no AuthProvider)
  // =======================================================================

  // ✅ Verificar se usuário está logado (MÉTODO DE INSTÂNCIA)
  Future<bool> isLoggedIn() async {
    final token = await AuthService.getAuthToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verify_token.php'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ✅ Obter usuário atual (MÉTODO DE INSTÂNCIA)
  Future<UserModel?> getCurrentUser() async {
    final token = await AuthService.getAuthToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user_profile.php'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['user'] != null) {
          final user = UserModel.fromJson(data['user']);
          // Salvar dados atualizados localmente
          await AuthService.saveUserData(data['user']);
          return user;
        }
      }

      // Se falhar a consulta no servidor, tentar dados locais
      final userData = await AuthService.getUserData();
      if (userData != null) {
        return UserModel.fromJson(userData);
      }

      return null;
    } catch (e) {
      // Em caso de erro, tentar dados locais
      final userData = await AuthService.getUserData();
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    }
  }

  // ✅ Login com email e senha (MÉTODO DE INSTÂNCIA)
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Salvar dados localmente
        if (data['token'] != null) {
          await AuthService.saveAuthToken(data['token']);
        }
        if (data['user'] != null) {
          await AuthService.saveUserData(data['user']);
        }
        if (data['company'] != null) {
          await AuthService.saveCompanyData(data['company']);
        }

        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Erro no login',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  // ✅ Registro de novo usuário (MÉTODO DE INSTÂNCIA)
  Future<AuthResponse> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  // ✅ Conectar conta Instagram (MÉTODO DE INSTÂNCIA)
  Future<AuthResponse> connectInstagram(
      String accessToken, String instagramCode) async {
    try {
      final userToken = await AuthService.getAuthToken();
      if (userToken == null) {
        return AuthResponse(success: false, message: 'Usuário não autenticado');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/connect_instagram.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'instagram_code': instagramCode,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      // Atualizar dados do usuário se sucesso
      if (data['success'] && data['user'] != null) {
        await AuthService.saveUserData(data['user']);
      }

      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Erro ao conectar Instagram: $e',
      );
    }
  }

  // Obter CNPJ da empresa
  static Future<Map<String, dynamic>?> getCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    final companyDataString = prefs.getString('company_data');
    if (companyDataString != null && companyDataString.isNotEmpty) {
      return jsonDecode(companyDataString);
    }
    return null;
  }

  // Obter token de autenticação
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fazer logout (versão estática)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('company_data');
    await prefs.remove('user_data');
    await prefs.remove('instagram_token');
    await prefs.remove('instagram_user_id');
  }

  // Salvar CNPJ da empresa
  static Future<void> saveCompanyData(Map<String, dynamic> companyData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('company_id', companyData['id'] ?? 0);
    await prefs.setString('company_cnpj', companyData['cmp_cnpj'] ?? '');
    await prefs.setString('company_name', companyData['cmp_companyName'] ?? '');
    await prefs.setString(
        'company_fantasyName', companyData['cmp_fantasyName'] ?? '');
    await prefs.setString('company_plan', companyData['cmp_plan'] ?? '');
  }

  // Salvar token de autenticação
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Obter dados completos do usuário (versão estática)
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_email');
      if (userDataString != null && userDataString.isNotEmpty) {
        return {
        'id': prefs.getInt('user_id') ?? 0,
        'name': prefs.getString('user_name') ?? '',
        'email': prefs.getString('user_email') ?? '',
        'role': prefs.getString('user_role') ?? '',
      };
    }
    return null;
  }

  // Salvar dados completos do usuário
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userData['id'] ?? 0);
    await prefs.setString('user_name', userData['name'] ?? '');
    await prefs.setString('user_email', userData['email'] ?? '');
    await prefs.setString('user_role', userData['role'] ?? '');
  }

  // Verificar se usuário está logado (versão estática - simples)
  static Future<bool> isLoggedInStatic() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Salvar token do Instagram
  static Future<void> saveInstagramToken(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('instagram_token', token);
    await prefs.setString('instagram_user_id', userId);
  }

  // Obter token do Instagram
  static Future<String?> getInstagramToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('instagram_token');
  }

  // Obter ID do usuário Instagram
  static Future<String?> getInstagramUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('instagram_user_id');
  }
}
