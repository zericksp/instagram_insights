// ========================================
// lib/services/instagram_api_service.dart
// ========================================

import 'dart:convert';
import 'package:http/http.dart' as http;

class InstagramApiService {
  static const String _baseUrl = 'https://graph.facebook.com/v23.0';
  static const String _accessToken = 'EAAHiJmTg9dkBPdoxZAJ3Ystlg2oKk1x3XyZBARg7OWGJVz2HxU137MIz2lr7jiZAYT9134JA56cctuOnDZAa0VOuKhxRevhMEviVW032NiTRKDGEXczzVj1dDtPwtZALK0LPGrZCa6QZBJOnRjWtEdnU65Jpdd7wyDbZAsYcCejdFpZB1UBZAwKSZBAemtTjnHCP5fcTZC8IFZC7V9tZAiHBJ39Xtm8SqOhxnWbVIoZCSPy';
  static const String _instagramAccountId = '17841415250388479';

  Future<Map<String, dynamic>> getOverviewData() async {
    try {
      // Buscar dados de seguidores e alcance
      const insightsUrl = '$_baseUrl/$_instagramAccountId/insights?'
          'metric=follower_count,reach&'
          'period=day&'
          'access_token=$_accessToken';

      final response = await http.get(Uri.parse(insightsUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final insights = data['data'] as List;
        
        int totalFollowers = 0;
        int totalReach = 0;
        List<Map<String, dynamic>> reachData = [];
        
        for (var insight in insights) {
          if (insight['name'] == 'follower_count') {
            final values = insight['values'] as List;
            if (values.isNotEmpty) {
              totalFollowers = values.last['value'] ?? 0;
            }
          } else if (insight['name'] == 'reach') {
            final values = insight['values'] as List;
            for (var value in values) {
              totalReach += (value['value'] as int);
              reachData.add({
                'date': value['end_time'],
                'reach': value['value'],
              });
            }
          }
        }

        return {
          'totalFollowers': totalFollowers,
          'totalReach': totalReach,
          'followersGrowth': 0, // Calcular baseado em dados históricos
          'reachGrowth': 0.15, // Exemplo de crescimento
          'reachData': reachData,
        };
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dados: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFollowersData() async {
    try {
      // Simular dados de seguidores por enquanto
      // Na implementação real, usar a API do Instagram
      return List.generate(7, (index) {
        final date = DateTime.now().subtract(Duration(days: 6 - index));
        return {
          'date': date.toIso8601String(),
          'followers': 100 + (index * 5) + (index % 2 == 0 ? 2 : -1),
        };
      });
    } catch (e) {
      throw Exception('Erro ao buscar dados de seguidores: $e');
    }
  }

  Future<Map<String, dynamic>> getEngagementData() async {
    // Implementar busca de dados de engajamento
    return {
      'engagementRate': 4.2,
      'totalInteractions': 328,
      'interactions': [
        {'type': 'likes', 'count': 133},
        {'type': 'comments', 'count': 17},
        {'type': 'shares', 'count': 14},
        {'type': 'saves', 'count': 63},
      ],
    };
  }

  Future<List<Map<String, dynamic>>> getContentData() async {
    // Implementar busca de dados de conteúdo
    return [
      {'id': '1', 'type': 'post', 'likes': 89, 'comments': 12, 'date': DateTime.now().subtract(const Duration(days: 1))},
      {'id': '2', 'type': 'video', 'likes': 156, 'comments': 23, 'date': DateTime.now().subtract(const Duration(days: 2))},
      {'id': '3', 'type': 'carousel', 'likes': 203, 'comments': 45, 'date': DateTime.now().subtract(const Duration(days: 3))},
    ];
  }
}