from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import detection, scene, currency

app = FastAPI(
    title="AI Mobile Assistant API",
    description="Backend API for AI Based Mobile Assistant for Visually Impaired Individuals",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(detection.router)
app.include_router(scene.router)
app.include_router(currency.router)

@app.get("/")
def root():
    return {"status": "AI Mobile Assistant API running"}
