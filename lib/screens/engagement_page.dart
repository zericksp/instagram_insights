// ========================================
// lib/screens/engagement_page.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EngagementPage extends StatefulWidget {
  const EngagementPage({Key? key}) : super(key: key);

  @override
  State<EngagementPage> createState() => _EngagementPageState();
}

class _EngagementPageState extends State<EngagementPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engajamento'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEngagementMetrics(),
            const SizedBox(height: 20),
            _buildInteractionChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMetrics() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Text('Taxa de Engajamento', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text('4.2%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple)),
                  Text('+0.3%', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Text('Interações Totais', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text('328', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple)),
                  Text('+15', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interação por Conteúdo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 133, color: Colors.blue)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 63, color: Colors.purple)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 62, color: Colors.pink)]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0: return const Text('Carrossel');
                            case 1: return const Text('Vídeo');
                            case 2: return const Text('Imagem');
                            default: return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}