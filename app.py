from flask import Flask, jsonify, request
from flask_cors import CORS
from data_fetcher import fetch_stock_data
from ml_model import predict_future_price
from analyzer import analyze_stock
app = Flask(__name__)
CORS(app)
@app.route("/getStockData", methods=["GET"])
def get_stock_data():
    symbol = request.args.get("symbol", "").strip().upper()
    if not symbol:
        return jsonify({"error": "Symbol is required"}), 400
    data = fetch_stock_data(symbol)
    if "error" in data:
        return jsonify(data), 404
    return jsonify(data), 200

@app.route("/predict", methods=["GET"])
def predict():
    symbol = request.args.get("symbol", "").strip().upper()
    if not symbol:
        return jsonify({"error": "Symbol is required"}), 400
    stock_data = fetch_stock_data(symbol)
    if "error" in stock_data:
        return jsonify(stock_data), 404
    prices = stock_data["prices"]
    prediction = predict_future_price(prices, months_ahead=12)
    prediction["symbol"] = symbol
    prediction["current_price"] = stock_data["current_price"]
    return jsonify(prediction), 200

@app.route("/analyze", methods=["GET"])
def analyze():
    symbol = request.args.get("symbol", "").strip().upper()
    if not symbol:
        return jsonify({"error": "Symbol is required"}), 400
    stock_data = fetch_stock_data(symbol)
    if "error" in stock_data:
        return jsonify(stock_data), 404
    prices = stock_data["prices"]
    dates = stock_data["dates"]
    analysis = analyze_stock(prices, dates)
    prediction = predict_future_price(prices)
    result = {
        "symbol": symbol,
        "company_name": stock_data["company_name"],
        "current_price": stock_data["current_price"],
        "currency": stock_data["currency"],
        "total_growth_pct": analysis["total_growth_pct"],
        "avg_yearly_growth": analysis["avg_yearly_growth"],
        "highest_price": analysis["highest_price"],
        "lowest_price": analysis["lowest_price"],
        "volatility": analysis["volatility"],
        "risk_level": analysis["risk_level"],
        "recommendation": analysis["recommendation"],
        "investment_type": analysis["investment_type"],
        "suggested_duration": analysis["suggested_duration"],
        "prediction": prediction,
    }
    return jsonify(result), 200
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "message": "Backend is running"}), 200
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)