import requests
import sys
import os

# replace with your actual token from poly.pizza
AUTH_TOKEN = "YOUR_POLY_PIZZA_TOKEN" 
SAVE_DIR = "assets/models"

def fetch_model(query):
    if not os.path.exists(SAVE_DIR):
        os.makedirs(SAVE_DIR)
        
    headers = {"x-auth-token": AUTH_TOKEN}
    url = f"https://api.poly.pizza/v1.1/search/{query}"
    
    print(f"🔍 Searching Poly Pizza for: {query}...")
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200 and len(response.json()) > 0:
        asset = response.json()[0]
        download_url = asset["DownloadURL"]
        file_name = f"{asset['Title'].replace(' ', '_')}.glb"
        dest = os.path.join(SAVE_DIR, file_name)
        
        print(f"📦 Found '{asset['Title']}'. Downloading...")
        file_data = requests.get(download_url).content
        with open(dest, "wb") as f:
            f.write(file_data)
        print(f"✅ Saved to {dest}")
        return dest
    else:
        print("❌ No models found or API error.")
        return None

if __name__ == "__main__":
    if len(sys.argv) > 1:
        fetch_model(sys.argv[1])
