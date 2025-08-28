from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import requests
import re

app = FastAPI()

# מאפשר לכל הדומיינים (Flutter Web) לשלוח בקשות
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # אפשר לשים את כתובת ה-frontend שלך
    allow_methods=["*"],
    allow_headers=["*"],
)

def fetch_preview_url(track_id: str) -> str | None:
    embed_url = f"https://open.spotify.com/embed/track/{track_id}"
    
    try:
        response = requests.get(embed_url)
        if response.status_code != 200:
            return None

        html = response.text
        # חיפוש audioPreview.url עם Regex
        match = re.search(r'"audioPreview"\s*:\s*{[^}]*"url"\s*:\s*"([^"]+)"', html)
        if match:
            return match.group(1)

    except Exception as e:
        print(f"Error: {e}")
    return None

@app.get("/preview/{track_id}")
def get_preview(track_id: str):
    preview_url = fetch_preview_url(track_id)
    if preview_url:
        return {"track_id": track_id, "preview_url": preview_url}
    else:
        raise HTTPException(status_code=404, detail="Preview not found")
