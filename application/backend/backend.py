from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.interval import IntervalTrigger
from datetime import datetime
import requests

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins. Replace "*" with specific domains in production.
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods (GET, POST, etc.)
    allow_headers=["*"],  # Allow all headers
)

# In-memory list to store Bitcoin prices with timestamps
bitcoin_prices =[]

# External API URL for Bitcoin price
COINGECKO_API = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"

def fetch_bitcoin_price():
    """Fetch the current Bitcoin price and append to the list with a timestamp."""
    try:
        response = requests.get(COINGECKO_API)
        if response.status_code == 200:
            data = response.json()
            price = data["bitcoin"]["usd"]
            timestamp = datetime.now().isoformat()  # Current timestamp
            bitcoin_prices.append({"price": price, "time": timestamp})
            # Limit the list to the latest 100 entries for memory efficiency
            if len(bitcoin_prices) > 100:
                bitcoin_prices.pop(0)
        else:
            print("Failed to fetch Bitcoin price")
    except Exception as e:
        print(f"Error fetching Bitcoin price: {e}")

# Schedule the price fetching every minute
scheduler = BackgroundScheduler()
scheduler.add_job(fetch_bitcoin_price, IntervalTrigger(seconds=60))
scheduler.start()

# API endpoint to get Bitcoin prices with timestamps
@app.get("/prices")
async def get_prices():
    return bitcoin_prices

# Shutdown the scheduler when the app stops
@app.on_event("shutdown")
def shutdown_event():
    scheduler.shutdown()
