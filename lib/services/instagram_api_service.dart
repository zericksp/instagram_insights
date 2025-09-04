// ========================================
// lib/services/instagram_api_service.dart - ATUALIZADO
// ========================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class InstagramApiService {
  static const String _baseUrl = 'https://graph.facebook.com/v18.0';
  static const String _tokenApiUrl =
      'https://tiven.com.br/api/instagram/get_token.php';

  // Cache do token em memória (obtido por CNPJ)
  static String? _cachedToken;
  static String? _cachedAccountId;
  static DateTime? _cacheExpiry;

  /// Buscar token da empresa logada via CNPJ
  static Future<Map<String, String?>> getActiveToken() async {
    // Verificar cache primeiro (válido por 30 minutos)
    if (_cachedToken != null &&
        _cacheExpiry != null &&
        DateTime.now().isBefore(_cacheExpiry!)) {
      return {
        'token': _cachedToken,
        'accountId': _cachedAccountId,
      };
    }

    try {
      // Obter CNPJ do usuário logado
      final cnpj = await AuthService.getCompanyCnpj();
      final authToken = await AuthService.getAuthToken();

      if (cnpj == null || authToken == null) {
        throw Exception('Usuário não está logado');
      }

      final response = await http.get(
        Uri.parse('$_tokenApiUrl?cnpj=$cnpj'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'].isNotEmpty) {
          final tokenData = data['data'][0];

          // Cachear token por 30 minutos
          _cachedToken = tokenData['itk_accessToken'];
          _cachedAccountId = tokenData['itk_instagramAccountId'];
          _cacheExpiry = DateTime.now().add(const Duration(minutes: 30));

          print('✅ Token obtido para CNPJ: $cnpj');

          return {
            'token': _cachedToken,
            'accountId': _cachedAccountId,
          };
        } else {
          throw Exception('Nenhum token encontrado para esta empresa');
        }
      } else if (response.statusCode == 401) {
        // Token expirado, fazer logout
        await AuthService.logout();
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao buscar token: $e');
      rethrow;
    }
  }

  /// Limpar cache de token
  static void clearTokenCache() {
    _cachedToken = null;
    _cachedAccountId = null;
    _cacheExpiry = null;
  }

  /// Método principal para buscar insights (atualizado)
  Future<Map<String, dynamic>> getOverviewData() async {
    final credentials = await getActiveToken();

    if (credentials['token'] == null || credentials['accountId'] == null) {
      throw Exception('Token de acesso não disponível para esta empresa');
    }

    final token = credentials['token']!;
    final accountId = credentials['accountId']!;

    try {
      final insightsUrl = '$_baseUrl/$accountId/insights?'
          'metric=follower_count,reach,impressions&'
          'period=day&'
          'access_token=$token';

      print('🔍 Buscando insights para conta: $accountId');

      final response = await http.get(Uri.parse(insightsUrl)).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('error')) {
          clearTokenCache();
          final errorMsg = data['error']['message'] ?? 'Token inválido';
          throw Exception('Erro da API Instagram: $errorMsg');
        }

        print('✅ Dados obtidos com sucesso');
        return _processInsightsData(data);
      } else if (response.statusCode == 401) {
        clearTokenCache();
        await AuthService.logout();
        throw Exception('Sessão expirada. Faça login novamente.');
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao buscar dados: $e');
      rethrow;
    }
  }

  /// Processar dados da API (sem mudanças)
  Map<String, dynamic> _processInsightsData(Map<String, dynamic> data) {
    final insights = data['data'] as List? ?? [];

    int totalFollowers = 0;
    int totalReach = 0;
    int totalImpressions = 0;
    List<Map<String, dynamic>> reachData = [];

    for (var insight in insights) {
      final name = insight['name'];
      final values = insight['values'] as List? ?? [];

      switch (name) {
        case 'follower_count':
          if (values.isNotEmpty) {
            totalFollowers = values.last['value'] ?? 0;
          }
          break;
        case 'reach':
          for (var value in values) {
            final reach = value['value'] as int? ?? 0;
            totalReach += reach;
            reachData.add({
              'date': value['end_time'] ?? DateTime.now().toIso8601String(),
              'reach': reach,
            });
          }
          break;
        case 'impressions':
          for (var value in values) {
            totalImpressions += (value['value'] as int? ?? 0);
          }
          break;
      }
    }

    return {
      'totalFollowers': totalFollowers,
      'totalReach': totalReach,
      'totalImpressions': totalImpressions,
      'followersGrowth': 0, // Calcular baseado em histórico
      'reachGrowth': totalReach > 0 ? 0.15 : 0,
      'reachData': reachData,
    };
  }

  /// Validar se usuário tem acesso (método de instância)
  Future<bool> validateToken() async {
    try {
      await getOverviewData();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Manter outros métodos existentes sem mudanças...
  Future<List<Map<String, dynamic>>> getFollowersData() async {
    return List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return {
        'date': date.toIso8601String(),
        'followers': 100 + (index * 5) + (index % 2 == 0 ? 2 : -1),
      };
    });
  }
}
