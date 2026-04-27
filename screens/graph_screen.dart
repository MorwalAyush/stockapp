import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
class GraphScreen extends StatelessWidget {
  final StockModel stockData;
  const GraphScreen({super.key, required this.stockData});
  @override
  Widget build(BuildContext context) {
    final prices = stockData.prices;
    final dates = stockData.dates;
    // Convert to chart points
    final spots = prices.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    // FIX: always use double (0.0, 100.0)
    final minY = prices.isEmpty
        ? 0.0
        : prices.reduce((a, b) => a < b ? a : b) * 0.95;
    final maxY = prices.isEmpty
        ? 100.0
        : prices.reduce((a, b) => a > b ? a : b) * 1.05;
    return Scaffold(
      appBar: AppBar(
        title: Text('${stockData.symbol} Chart'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Current Price
            Text(
              '${stockData.currency} ${NumberFormat('#,##,###').format(stockData.currentPrice)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('All Time Performance'),
            const SizedBox(height: 10),
            // Chart
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (spots.length / 4).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i >= dates.length) return const SizedBox();
                          return Text(
                            dates[i].substring(0, 7),
                            style: const TextStyle(fontSize: 8),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // High / Low
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('High: ${maxY.toStringAsFixed(0)}'),
                Text('Low: ${minY.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}