import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.6:5000';

  // GET STOCK DATA
  static Future<StockModel> getStockData(String symbol) async {
    try {
      final uri = Uri.parse('$baseUrl/getStockData?symbol=$symbol');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['error'] != null) throw Exception(json['error']);
        return StockModel.fromJson(json);
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ANALYZE STOCK (Prediction + Analysis)
  static Future<AnalysisModel> analyzeStock(String symbol) async {
    try {
      final uri = Uri.parse('$baseUrl/analyze?symbol=$symbol');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 60),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['error'] != null) throw Exception(json['error']);
        return AnalysisModel.fromJson(json);
      } else {
        throw Exception('Failed to load analysis');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  // HEALTH CHECK
  static Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}