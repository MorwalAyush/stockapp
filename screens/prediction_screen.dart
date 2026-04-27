import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
class PredictionScreen extends StatelessWidget {
  final AnalysisModel analysis;
  const PredictionScreen({super.key, required this.analysis});
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
    final pred = analysis.prediction;

    final expectedReturn = pred.finalPredictedPrice > 0
        ? ((pred.finalPredictedPrice - analysis.currentPrice) /
        analysis.currentPrice *
        100)
        .toStringAsFixed(1)
        : '0';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('${analysis.symbol} Prediction',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //ML Prediction Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: pred.trend == 'upward'
                      ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                      : [const Color(0xFFB71C1C), const Color(0xFFC62828)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        pred.trend == 'upward'
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      const Text('ML Price Prediction',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Predicted Price (12 months)',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(
                    '${analysis.currency} ${NumberFormat('#,##,###.##').format(pred.finalPredictedPrice)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _predInfoChip('Current',
                          '${analysis.currency} ${NumberFormat('#,##,###').format(analysis.currentPrice)}'),

                      _predInfoChip('Return', '$expectedReturn%'),

                      _predInfoChip('Trend',
                          pred.trend == 'upward' ? '↑ Up' : '↓ Down'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accuracy: ${(pred.r2Score * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Recommendation Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Main suggestion
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getInvestmentColor(analysis.investmentType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      analysis.recommendation,
                      style: TextStyle(
                        color: _getInvestmentColor(analysis.investmentType),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _recRow(Icons.access_time, 'Type',
                      analysis.investmentType,
                      _getInvestmentColor(analysis.investmentType)),
                  const Divider(),
                  _recRow(Icons.calendar_today, 'Duration',
                      analysis.suggestedDuration,
                      Colors.blue),
                  const Divider(),
                  _recRow(Icons.shield, 'Risk',
                      analysis.riskLevel,
                      _getRiskColor(analysis.riskLevel)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _predInfoChip(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
  Widget _recRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}