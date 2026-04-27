// STOCK MODEL
class StockModel {
  final String symbol;
  final String companyName;
  final double currentPrice;
  final dynamic marketCap;
  final String currency;
  final List<String> dates;
  final List<double> prices;
  StockModel({
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.marketCap,
    required this.currency,
    required this.dates,
    required this.prices,
  });
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] ?? '',
      companyName: json['company_name'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      marketCap: json['market_cap'],
      currency: json['currency'] ?? 'INR',
      dates: List<String>.from(json['dates'] ?? []),
      prices: List<double>.from(
        (json['prices'] ?? []).map((p) => p.toDouble()),
      ),
    );
  }
}
// PREDICTION MODEL
class PredictionModel {
  final List<double> predictedPrices;
  final double finalPredictedPrice;
  final double r2Score;
  final String trend;
  PredictionModel({
    required this.predictedPrices,
    required this.finalPredictedPrice,
    required this.r2Score,
    required this.trend,
  });
  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      predictedPrices: List<double>.from(
        (json['predicted_prices'] ?? []).map((p) => p.toDouble()),
      ),
      finalPredictedPrice: (json['final_predicted_price'] ?? 0).toDouble(),
      r2Score: (json['r2_score'] ?? 0).toDouble(),
      trend: json['trend'] ?? 'unknown',
    );
  }
}
// ANALYSIS MODEL
class AnalysisModel {
  final String symbol;
  final String companyName;
  final double currentPrice;
  final String currency;
  final double highestPrice;
  final double lowestPrice;
  final String riskLevel;
  final String recommendation;
  final String investmentType;
  final String suggestedDuration;
  final PredictionModel prediction;
  AnalysisModel({
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.currency,
    required this.highestPrice,
    required this.lowestPrice,
    required this.riskLevel,
    required this.recommendation,
    required this.investmentType,
    required this.suggestedDuration,
    required this.prediction,
  });
  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      symbol: json['symbol'] ?? '',
      companyName: json['company_name'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      highestPrice: (json['highest_price'] ?? 0).toDouble(),
      lowestPrice: (json['lowest_price'] ?? 0).toDouble(),
      riskLevel: json['risk_level'] ?? 'Unknown',
      recommendation: json['recommendation'] ?? '',
      investmentType: json['investment_type'] ?? '',
      suggestedDuration: json['suggested_duration'] ?? '',
      prediction: PredictionModel.fromJson(json['prediction'] ?? {}),
    );
  }
}
