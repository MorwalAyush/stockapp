import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'details_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  final List<Map<String, String>> popularStocks = [
    {'name': 'TCS', 'symbol': 'TCS.NS', 'desc': 'Tata Consultancy Services'},
    {'name': 'Reliance', 'symbol': 'RELIANCE.NS', 'desc': 'Reliance Industries'},
    {'name': 'HDFC Bank', 'symbol': 'HDFCBANK.NS', 'desc': 'HDFC Bank Limited'},
    {'name': 'Infosys', 'symbol': 'INFY.NS', 'desc': 'Infosys Limited'},
    {'name': 'SBI', 'symbol': 'SBIN.NS', 'desc': 'State Bank of India'},
    {'name': 'Wipro', 'symbol': 'WIPRO.NS', 'desc': 'Wipro Limited'},
    {'name': 'ICICI Bank', 'symbol': 'ICICIBANK.NS', 'desc': 'ICICI Bank Limited'},
    {'name': 'Bajaj Finance', 'symbol': 'BAJFINANCE.NS', 'desc': 'Bajaj Finance Ltd'},
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _searchStock(String symbol) async {
    if (symbol.trim().isEmpty) return;
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final stockData = await ApiService.getStockData(symbol.trim().toUpperCase());
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => DetailsScreen(stockData: stockData),
        ));
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not find stock. Try adding .NS\ne.g. TCS.NS, SBIN.NS');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Stock Analyzer', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _buildStocksTab(),
    );
  }
  Widget _buildStocksTab() {
    bool _showCompare = false;
    final TextEditingController _c1 = TextEditingController();
    final TextEditingController _c2 = TextEditingController();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Card ──
          Container(
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
                const Text('Search Stocks', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Enter symbol (e.g. TCS.NS)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. TCS.NS, SBIN.NS, INFY.NS',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        ),
                        onSubmitted: _searchStock,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _searchStock(_searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF185FA5),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Go', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade400),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_errorMessage, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text('Popular Indian Stocks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 1.6, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: popularStocks.length,
            itemBuilder: (context, index) {
              final stock = popularStocks[index];
              return GestureDetector(
                onTap: () => _searchStock(stock['symbol']!),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(stock['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(stock['desc']!, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFE6F1FB), borderRadius: BorderRadius.circular(6)),
                        child: Text(stock['symbol']!, style: const TextStyle(color: Color(0xFF185FA5), fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}