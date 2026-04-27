import numpy as np

def analyze_stock(prices: list, dates: list) -> dict:
    if len(prices) < 2:
        return {"error": "Insufficient data"}

    prices = np.array(prices)

    current_price = prices[-1]
    oldest_price = prices[0]
    highest_price = float(np.max(prices))
    lowest_price = float(np.min(prices))

    total_growth_pct = round(
        ((current_price - oldest_price) / oldest_price) * 100, 2
    )
    years = len(prices) / 12
    avg_yearly_growth = round(
        total_growth_pct / years, 2
    ) if years > 0 else 0

    monthly_returns = np.diff(prices) / prices[:-1] * 100
    volatility = round(float(np.std(monthly_returns)), 2)

    if volatility < 3:
        risk_level = "Low"
    elif volatility < 6:
        risk_level = "Medium"
    else:
        risk_level = "High"

    if avg_yearly_growth > 15 and risk_level == "Low":
        recommendation = "Strong Buy — Excellent long-term investment"
        investment_type = "Long-Term"
        suggested_duration = "5–10 years"
    elif avg_yearly_growth > 10 and risk_level in ["Low", "Medium"]:
        recommendation = "Buy — Good growth potential"
        investment_type = "Long-Term"
        suggested_duration = "3–5 years"
    elif avg_yearly_growth > 5:
        recommendation = "Hold — Moderate growth, consider short-term"
        investment_type = "Short-Term"
        suggested_duration = "1–2 years"
    elif avg_yearly_growth > 0:
        recommendation = "Caution — Low growth, monitor closely"
        investment_type = "Short-Term"
        suggested_duration = "6–12 months"
    else:
        recommendation = "Avoid — Declining trend detected"
        investment_type = "Avoid"
        suggested_duration = "N/A"

    return {
        "total_growth_pct": total_growth_pct,
        "avg_yearly_growth": avg_yearly_growth,
        "highest_price": round(highest_price, 2),
        "lowest_price": round(lowest_price, 2),
        "volatility": volatility,
        "risk_level": risk_level,
        "recommendation": recommendation,
        "investment_type": investment_type,
        "suggested_duration": suggested_duration,
    }