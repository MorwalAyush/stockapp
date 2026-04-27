import requests
import pandas as pd
from datetime import datetime, timedelta
import time
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Accept": "application/json",
    "Accept-Language": "en-US,en;q=0.9",
}
# Known Indian stock symbols mapping
STOCK_INFO = {
    "TCS": {"name": "Tata Consultancy Services", "bse": "532540"},
    "RELIANCE": {"name": "Reliance Industries", "bse": "500325"},
    "HDFCBANK": {"name": "HDFC Bank Limited", "bse": "500180"},
    "INFY": {"name": "Infosys Limited", "bse": "500209"},
    "SBIN": {"name": "State Bank of India", "bse": "500112"},
    "WIPRO": {"name": "Wipro Limited", "bse": "507685"},
    "ICICIBANK": {"name": "ICICI Bank Limited", "bse": "532174"},
    "BAJFINANCE": {"name": "Bajaj Finance Limited", "bse": "500034"},
    "HINDUNILVR": {"name": "Hindustan Unilever", "bse": "500696"},
    "TATAMOTORS": {"name": "Tata Motors Limited", "bse": "500570"},
    "ADANIENT": {"name": "Adani Enterprises", "bse": "512599"},
    "MARUTI": {"name": "Maruti Suzuki India", "bse": "532500"},
    "AXISBANK": {"name": "Axis Bank Limited", "bse": "532215"},
    "KOTAKBANK": {"name": "Kotak Mahindra Bank", "bse": "500247"},
    "LT": {"name": "Larsen & Toubro", "bse": "500510"},
}
def fetch_stock_data(symbol: str) -> dict:
    # Clean symbol - remove .NS .BSE suffix
    clean = symbol.upper().replace(".NS", "").replace(".BSE", "").replace(".BO", "")
    print(f"Fetching data for: {clean}")
    # Try Stooq (very reliable, no blocks)
    result = fetch_via_stooq(clean)
    if "error" not in result:
        return result
    print(f"Stooq failed: {result['error']}, trying fallback...")
    # Fallback to generated realistic data for demo
    return fetch_demo_data(clean)

def fetch_via_stooq(symbol: str) -> dict:
    try:
        # Stooq uses .IN suffix for Indian NSE stocks
        stooq_symbol = f"{symbol}.IN"
        end_date = datetime.now().strftime("%Y%m%d")
        start_date = (datetime.now() - timedelta(days=365*10)).strftime("%Y%m%d")
        url = f"https://stooq.com/q/d/l/?s={stooq_symbol}&d1={start_date}&d2={end_date}&i=m"
        print(f"Trying stooq: {url}")
        resp = requests.get(url, headers=HEADERS, timeout=30)
        if resp.status_code != 200:
            return {"error": f"Stooq returned status {resp.status_code}"}
        # Parse CSV response
        from io import StringIO
        df = pd.read_csv(StringIO(resp.text))
        if df.empty or "Close" not in df.columns:
            return {"error": "No data in stooq response"}
        if len(df) < 5:
            return {"error": "Insufficient data from stooq"}
        df["Date"] = pd.to_datetime(df["Date"])
        df = df.set_index("Date").sort_index()
        df = df[["Close"]].dropna()
        df.index = df.index.strftime("%Y-%m")
        current_price = round(float(df["Close"].iloc[-1]), 2)
        # Get company name
        info = STOCK_INFO.get(symbol, {})
        company_name = info.get("name", symbol)
        print(f"Stooq success: {symbol}, rows={len(df)}")
        return {
            "symbol": symbol.upper(),
            "company_name": company_name,
            "current_price": current_price,
            "market_cap": "N/A",
            "currency": "INR",
            "dates": df.index.tolist(),
            "prices": [round(float(p), 2) for p in df["Close"].tolist()],
        }
    except Exception as e:
        return {"error": str(e)}
def fetch_demo_data(symbol: str) -> dict:
    """
    Generate realistic demo data based on known stock performance.
    Used as fallback when all APIs fail.
    """
    import numpy as np
    # Base prices for known stocks (approximate 2014 prices in INR)
    base_prices = {
        "TCS": 2200, "RELIANCE": 900, "HDFCBANK": 650,
        "INFY": 1800, "SBIN": 200, "WIPRO": 550,
        "ICICIBANK": 250, "BAJFINANCE": 1500, "HINDUNILVR": 600,
        "TATAMOTORS": 400, "ADANIENT": 150, "MARUTI": 2500,
        "AXISBANK": 350, "KOTAKBANK": 700, "LT": 1200,
    }
    base = base_prices.get(symbol, 500)
    info = STOCK_INFO.get(symbol, {"name": symbol})
    # Generate 10 years of monthly data with realistic growth
    np.random.seed(hash(symbol) % 2**31)
    months = 120  # 10 years
    dates = []
    prices = []
    price = float(base)
    start_date = datetime.now() - timedelta(days=365*10)
    for i in range(months):
        date = start_date + timedelta(days=30*i)
        dates.append(date.strftime("%Y-%m"))
        # Realistic monthly growth with volatility
        monthly_return = np.random.normal(0.012, 0.06)
        price = price * (1 + monthly_return)
        price = max(price, base * 0.3)
        prices.append(round(price, 2))
    current_price = prices[-1]
    print(f"Using demo data for {symbol}")
    return {
        "symbol": symbol.upper(),
        "company_name": info.get("name", symbol),
        "current_price": current_price,
        "market_cap": "N/A",
        "currency": "INR",
        "dates": dates,
        "prices": prices,
        "note": "Demo data — live API temporarily unavailable",
    }