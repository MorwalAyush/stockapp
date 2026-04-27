import numpy as np
from sklearn.linear_model import LinearRegression

def predict_future_price(prices: list, months_ahead: int = 12) -> dict:
    if len(prices) < 10:
        return {"error": "Not enough data for prediction"}

    X = np.arange(len(prices)).reshape(-1, 1)
    y = np.array(prices)

    model = LinearRegression()
    model.fit(X, y)

    future_indices = np.arange(
        len(prices), len(prices) + months_ahead
    ).reshape(-1, 1)
    predicted_prices = model.predict(future_indices)
    predicted_prices = [round(float(p), 2) for p in predicted_prices]

    r2 = round(float(model.score(X, y)), 4)

    return {
        "predicted_prices": predicted_prices,
        "final_predicted_price": predicted_prices[-1],
        "r2_score": r2,
        "trend": "upward" if model.coef_[0] > 0 else "downward",
    }