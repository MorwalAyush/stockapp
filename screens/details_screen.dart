import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'graph_screen.dart';
import 'prediction_screen.dart';
class DetailsScreen extends StatefulWidget {
  final StockModel stockData;
  const DetailsScreen({super.key, required this.stockData});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}
class _DetailsScreenState extends State<DetailsScreen> {
  bool _isLoadingAnalysis = false;
  AnalysisModel? _analysis;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }
  Future<void> _loadAnalysis() async {
    setState(() {
      _isLoadingAnalysis = true;
      _errorMessage = '';
    });
    try {
      final analysis = await ApiService.analyzeStock(widget.stockData.symbol);
      setState(() => _analysis = analysis);
    } catch (e) {
      setState(() => _errorMessage = 'Could not load analysis.');
    } finally {
      setState(() => _isLoadingAnalysis = false);
    }
  }
  String _formatMarketCap(dynamic cap) {
    if (cap == null || cap == 'N/A') return 'N/A';
    final num value = cap is num ? cap : num.tryParse(cap.toString()) ?? 0;
    if (value >= 1e12) return '₹${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '₹${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e7) return '₹${(value / 1e7).toStringAsFixed(2)}Cr';
    return '₹${NumberFormat('#,##,###').format(value)}';
  }
  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low': return Colors.green;
      case 'medium': return Colors.orange;
      case 'high': return Colors.red;
      default: return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    final stock = widget.stockData;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(stock.companyName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Price Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF185FA5), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stock.symbol,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(stock.companyName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Price',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text(
                            '${stock.currency} ${NumberFormat('#,##,###.##').format(stock.currentPrice)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Market Cap',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text(
                            _formatMarketCap(stock.marketCap),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Action Buttons ──
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GraphScreen(stockData: stock),
                      ),
                    ),
                    icon: const Icon(Icons.show_chart),
                    label: const Text('View Graph'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF185FA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _analysis == null
                        ? null
                        : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PredictionScreen(analysis: _analysis!),
                      ),
                    ),
                    icon: const Icon(Icons.auto_graph),
                    label: const Text('Prediction'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ── Analysis Section ──
            const Text('Stock Analysis',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_isLoadingAnalysis)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Loading analysis...',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_errorMessage,
                    style: TextStyle(color: Colors.red.shade700)),
              )
            else if (_analysis != null) ...[
                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _statCard('Highest Price',
                        '${stock.currency} ${NumberFormat('#,##,###').format(_analysis!.highestPrice)}',
                        Icons.arrow_upward, Colors.orange),
                    _statCard('Lowest Price',
                        '${stock.currency} ${NumberFormat('#,##,###').format(_analysis!.lowestPrice)}',
                        Icons.arrow_downward, Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                // Risk Card
                Container(
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getRiskColor(_analysis!.riskLevel)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.shield,
                            color: _getRiskColor(_analysis!.riskLevel),
                            size: 28),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Risk Level',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                          Text(_analysis!.riskLevel,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _getRiskColor(
                                      _analysis!.riskLevel))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
  Widget _statCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(title,
              style:
              const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}