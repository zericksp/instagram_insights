// ========================================
// lib/screens/overview_page.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/instagram_api_service.dart';
import '../widgets/metric_card.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final InstagramApiService _apiService = InstagramApiService();
  Map<String, dynamic>? _overviewData;
  bool _isLoading = true;
  late bool isValid;
  late String errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  Future<void> _loadOverviewData() async {
    try {
      final data = await _apiService.getOverviewData();
      setState(() {
        _overviewData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Insights'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOverviewData,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showTokenStatus(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOverviewData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMetricsCards(),
                    const SizedBox(height: 20),
                    _buildReachChart(),
                    const SizedBox(height: 20),
                    _buildTopContentCard(),
                  ],
                ),
              ),
            ),
    );
  }

  /// Mostrar status do token e opções
  void _showTokenStatus(BuildContext context) async {
    try {
      await _apiService.getOverviewData(); // ✅ USA INSTÂNCIA
      isValid = true;
    } catch (e) {
      isValid = false;
      errorMessage = e.toString();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status do Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isValid ? 'Token Válido' : 'Token Inválido',
                  style: TextStyle(
                    color: isValid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Este app busca automaticamente tokens atualizados do servidor. '
              'Se houver problemas, tente renovar o token.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          if (!isValid)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _refreshToken();
              },
              child: const Text('Renovar Token'),
            ),
        ],
      ),
    );
  }

  /// Renovar token manualmente
  Future<void> _refreshToken() async {
    setState(() => _isLoading = true);

    try {
      await InstagramApiService.refreshToken();
      await Future.delayed(const Duration(seconds: 2)); // Aguardar renovação
      await _loadOverviewData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache limpo! Tentando obter novo token...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao renovar token: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Testar conexão com servidor de tokens
  Future<void> _testServerConnection() async {
    setState(() => _isLoading = true);

    try {
      final isConnected = await InstagramApiService.testTokenServerConnection();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isConnected
                ? '✅ Servidor acessível! Verifique configuração dos tokens no backend.'
                : '❌ Servidor não acessível. Configure a URL da API ou verifique se o backend está rodando.'),
            backgroundColor: isConnected ? Colors.orange : Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao testar conexão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMetricsCards() {
    if (_overviewData == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Seguidores',
            value: _overviewData!['totalFollowers']?.toString() ?? '0',
            icon: Icons.people,
            color: Colors.blue,
            change: _overviewData!['followersGrowth']?.toString() ?? '0',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MetricCard(
            title: 'Alcance',
            value: _formatNumber(_overviewData!['totalReach'] ?? 0),
            icon: Icons.visibility,
            color: Colors.green,
            change:
                '+${((_overviewData!['reachGrowth'] ?? 0) * 100).toStringAsFixed(1)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildReachChart() {
    if (_overviewData == null || _overviewData!['reachData'] == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Dados não disponíveis')),
        ),
      );
    }

    final reachData = _overviewData!['reachData'] as List;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alcance dos últimos 7 dias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatNumber(value.toInt()),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < reachData.length) {
                            final date = DateTime.parse(
                                reachData[value.toInt()]['date']);
                            return Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: reachData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['reach'].toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.pink,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.pink.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Publicações mais relevantes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image),
                  ),
                  title: Text('Post ${index + 1}'),
                  subtitle: const Text('Descrição do post...'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${(index + 1) * 150}'),
                      const Text('curtidas', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
