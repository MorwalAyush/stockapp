import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
// STOCK CHART WIDGET
class StockChart extends StatefulWidget {
  final List<double> prices;
  final List<String> dates;
  final String currency;
  const StockChart({
    super.key,
    required this.prices,
    required this.dates,
    required this.currency,
  });
  @override
  State<StockChart> createState() => _StockChartState();
}
class _StockChartState extends State<StockChart> {
  int? _touchedIndex;
  List<FlSpot> _getSpots() {
    return widget.prices.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }
  Color _getLineColor() {
    if (widget.prices.length < 2) return const Color(0xFF185FA5);
    return widget.prices.last >= widget.prices.first
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);
  }
  @override
  Widget build(BuildContext context) {
    if (widget.prices.isEmpty) {
      return const Center(
        child: Text('No chart data available',
            style: TextStyle(color: Colors.grey)),
      );
    }
    final spots = _getSpots();
    final minY = widget.prices.reduce((a, b) => a < b ? a : b) * 0.92;
    final maxY = widget.prices.reduce((a, b) => a > b ? a : b) * 1.08;
    final lineColor = _getLineColor();
    final isPositive = widget.prices.last >= widget.prices.first;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${isPositive ? '+' : ''}${(((widget.prices.last - widget.prices.first) / widget.prices.first) * 100).toStringAsFixed(1)}% overall',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 65,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        NumberFormat.compact().format(value),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: (spots.length / 5).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= widget.dates.length) {
                        return const SizedBox();
                      }
                      final label = widget.dates[idx];
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          label.length >= 7 ? label.substring(0, 7) : label,
                          style: const TextStyle(
                              fontSize: 9, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                      color: Colors.grey.shade300, width: 1),
                  left: BorderSide(
                      color: Colors.grey.shade300, width: 1),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: lineColor,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      final isFirst = index == 0;
                      final isLast = index == spots.length - 1;
                      final isTouched = index == _touchedIndex;
                      if (isFirst || isLast || isTouched) {
                        return FlDotCirclePainter(
                          radius: isTouched ? 6 : 4,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      }
                      return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                          strokeWidth: 0,
                          strokeColor: Colors.transparent);
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        lineColor.withOpacity(0.25),
                        lineColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  setState(() {
                    _touchedIndex =
                    response?.lineBarSpots?.isNotEmpty == true
                        ? response!.lineBarSpots!.first.x.toInt()
                        : null;
                  });
                },
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 10,
                  getTooltipItems: (touchedSpots) =>
                      touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final date = idx < widget.dates.length
                            ? widget.dates[idx]
                            : '';
                        return LineTooltipItem(
                          '$date\n',
                          const TextStyle(
                              color: Colors.white70, fontSize: 11),
                          children: [
                            TextSpan(
                              text:
                              '${widget.currency} ${NumberFormat('#,##,###.##').format(spot.y)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// RECOMMENDATION CARD WIDGET
class RecommendationCard extends StatelessWidget {
  final AnalysisModel analysis;
  const RecommendationCard({super.key, required this.analysis});
  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low': return Colors.green;
      case 'medium': return Colors.orange;
      case 'high': return Colors.red;
      default: return Colors.grey;
    }
  }
  Color _getInvestmentColor(String type) {
    switch (type.toLowerCase()) {
      case 'long-term': return Colors.blue;
      case 'short-term': return Colors.orange;
      case 'avoid': return Colors.red;
      default: return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommendation',
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _row(Icons.lightbulb, analysis.recommendation,
              _getInvestmentColor(analysis.investmentType)),
          const Divider(height: 20),
          _row(Icons.access_time, analysis.investmentType,
              _getInvestmentColor(analysis.investmentType)),
          const Divider(height: 20),
          _row(Icons.calendar_today, analysis.suggestedDuration,
              Colors.blue),
          const Divider(height: 20),
          _row(Icons.shield, 'Risk: ${analysis.riskLevel}',
              _getRiskColor(analysis.riskLevel)),
        ],
      ),
    );
  }
  Widget _row(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ],
    );
  }
}