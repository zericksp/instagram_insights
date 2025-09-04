// ========================================
// lib/widgets/simple_chart.dart - ALTERNATIVA SIMPLES
// ========================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SimpleChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const SimpleChart({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Sem dados disponíveis'));
    }

    // Encontrar valores máximo e mínimo
    final values = data.map((e) => (e['reach'] as num).toDouble()).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Eixo Y (valores)
              SizedBox(
                width: 50,
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatNumber(maxValue.toInt()),
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      _formatNumber((maxValue / 2).toInt()),
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      _formatNumber(minValue.toInt()),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Gráfico
              Expanded(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final value = (item['reach'] as num).toDouble();
                      final normalizedHeight = range > 0 
                          ? ((value - minValue) / range) * 160 + 20
                          : 20.0;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Barra
                              Container(
                                height: normalizedHeight,
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.pink,
                                      Colors.pink.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Data
                              Text(
                                DateFormat('dd/MM').format(
                                  DateTime.parse(item['date']),
                                ),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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