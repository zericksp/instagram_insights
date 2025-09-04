// ========================================
// lib/screens/followers_page.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/instagram_api_service.dart';

class FollowersPage extends StatefulWidget {
  const FollowersPage({Key? key}) : super(key: key);

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  final InstagramApiService _apiService = InstagramApiService();
  List<Map<String, dynamic>> _followersData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowersData();
  }

  Future<void> _loadFollowersData() async {
    try {
      final data = await _apiService.getFollowersData();
      setState(() {
        _followersData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguidores'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFollowersData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFollowersData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFollowersChart(),
                    const SizedBox(height: 20),
                    _buildDemographicsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFollowersChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crescimento de Seguidores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _followersData.isEmpty
                  ? const Center(child: Text('Sem dados'))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < _followersData.length) {
                                  final date = DateTime.parse(
                                      _followersData[value.toInt()]['date']);
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
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _followersData.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                entry.value['followers'].toDouble(),
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
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

  Widget _buildDemographicsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demografia dos Seguidores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Por Região',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: 242,
                                color: Colors.orange,
                                title: 'SP',
                                radius: 40,
                              ),
                              PieChartSectionData(
                                value: 138,
                                color: Colors.deepOrange,
                                title: 'CE',
                                radius: 40,
                              ),
                              PieChartSectionData(
                                value: 48,
                                color: Colors.orange.shade300,
                                title: 'RJ',
                                radius: 40,
                              ),
                              PieChartSectionData(
                                value: 41,
                                color: Colors.orange.shade200,
                                title: 'MG',
                                radius: 40,
                              ),
                              PieChartSectionData(
                                value: 33,
                                color: Colors.orange.shade100,
                                title: 'Outros',
                                radius: 40,
                              ),
                            ],
                            centerSpaceRadius: 30,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: const [
                      Text('Por Idade',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 12),
                      ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Colors.blue, child: Text('25-34')),
                        title: Text('35%'),
                        dense: true,
                      ),
                      ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text('18-24')),
                        title: Text('28%'),
                        dense: true,
                      ),
                      ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Text('35-44')),
                        title: Text('22%'),
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
