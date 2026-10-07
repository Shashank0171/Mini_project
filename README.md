# AI Mobile Assistant

A powerful, AI-driven mobile assistant designed to aid users (especially the visually impaired) by providing real-time voice-first multilingual scene descriptions, object detection, text reading (OCR), and navigation assistance.

## Features

- **Object Detection**: Identifies objects in real-time using YOLOv8.
- **Scene Description**: Generates rich descriptions of the surroundings using Salesforce BLIP.
- **Text Recognition (OCR)**: Extracts and reads aloud text from images.
- **Navigation (GPS)**: Provides location tracking and route assistance via OpenStreetMap.
- **Multilingual Support**: Supports multiple languages (e.g., English, Hindi, Telugu) with seamless voice feedback.
- **Voice-First Interface**: Designed to be navigated through voice commands and text-to-speech.

## Architecture

The system is split into two primary components:
1. **Frontend (Flutter)**: A cross-platform mobile application that captures sensor data (camera, GPS, microphone) and presents a voice-first interface.
2. **Backend (Python/FastAPI)**: A robust set of RESTful APIs running heavy AI inference tasks (YOLOv8, BLIP).

## Tech Stack

- **Frontend**: Flutter, Dart
- **Backend**: Python, FastAPI, Uvicorn
- **AI/ML**: PyTorch, Ultralytics (YOLOv8), HuggingFace Transformers (BLIP)
- **Mapping**: OpenStreetMap

## Prerequisites

- **Flutter SDK**: `^3.0.0` or higher
- **Python**: `3.9` or higher
- **Android Studio / Xcode** for building the mobile application.

## Setup Instructions

### Python Backend Setup

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```
2. **Create a virtual environment (recommended):**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
4. **Environment Variables:**
   Copy the example config and adjust as needed:
   ```bash
   cp .env.example .env
   ```
5. **Run the backend server:**
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

### AI Models Setup (YOLOv8 & BLIP)

- **YOLOv8**: The YOLOv8n model will automatically download on the first run of the object detection service. Alternatively, place your custom `.pt` file in `backend/models/` and update `.env`.
- **BLIP**: The HuggingFace Transformers library will automatically download and cache `Salesforce/blip-image-captioning-base` locally on the first run.

### Flutter Setup

1. **Navigate to the flutter directory:**
   ```bash
   cd frontend
   ```
2. **Get packages:**
   ```bash
   flutter pub get
   ```
3. **Run the app:**
   ```bash
   flutter run
   ```

### OCR and OpenStreetMap Setup

- **OCR**: Integrated directly via the Google ML Kit package in Flutter, or handled server-side (if implemented as an extension endpoint).
- **OpenStreetMap**: Uses `flutter_map` and `latlong2`. No API key is required for basic tile servers, though rate limits apply.

### Android Permissions

Ensure the following permissions are configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Connecting Frontend to Backend

Update your Flutter app's `api_service.dart` (or `.env` equivalent in Flutter) to point to your backend IP.
*Note: If running on an Android Emulator, `10.0.2.2` points to your host machine's localhost.*

## API Documentation

Once the FastAPI backend is running, visit:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

### Endpoints
- `GET /health` : Health check.
- `POST /detect` : Accepts `multipart/form-data` with an image file. Returns detected objects and confidence.
- `POST /describe` : Accepts `multipart/form-data` with an image file. Returns a descriptive string of the scene.

## Multilingual Support

The Flutter app leverages `flutter_localizations` alongside native TTS (Text-to-Speech) engines. Ensure the host device has the appropriate language packs downloaded for offline TTS in languages like Hindi and Telugu.

## Project Structure Tree

```
.
├── backend
│   ├── .env.example
│   ├── main.py
│   ├── models/
│   ├── requirements.txt
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── detection.py
│   │   └── scene.py
│   └── services/
│       ├── __init__.py
│       ├── detection_service.py
│       └── scene_service.py
└── README.md
```

## Troubleshooting

- **PyTorch Installation**: If you face issues with PyTorch on Windows/Mac, visit the [PyTorch website](https://pytorch.org/) to generate the exact installation command for your environment.
- **Port Conflicts**: If port 8000 is occupied, run uvicorn with a different port (e.g., `--port 8080`) and update the Flutter client accordingly.
- **Model Downloads Failing**: Ensure stable internet connection during the first run. 

## Known Limitations

- High latency on older mobile devices without an internet connection (since processing is offloaded to the backend).
- BLIP model requires considerable RAM/VRAM. Adjust to smaller models if running on constrained hardware.

## Future Scope

- **Edge AI**: Migrate models to TFLite or ONNX for on-device inference without backend reliance.
- **Continuous Learning**: Allow users to teach the system new objects.
- **Enhanced Navigation**: Integration with indoor navigation beacons.
