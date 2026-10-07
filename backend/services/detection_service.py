import os
from ultralytics import YOLO
from dotenv import load_dotenv

load_dotenv()

class DetectionService:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(DetectionService, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        self.model_path = os.getenv("YOLO_MODEL_PATH", "models/yolov8n.pt")
        self.confidence_threshold = float(os.getenv("CONFIDENCE_THRESHOLD", "0.5"))
        self.model = None
        
        try:
            if os.path.exists(self.model_path) or self.model_path.endswith('.pt'):
                 self.model = YOLO(self.model_path)
            else:
                 print(f"Warning: YOLO model not found at {self.model_path}")
        except Exception as e:
            print(f"Error initializing YOLO model: {e}")

    def detect(self, image_path):
        if self.model is None:
            return []
            
        results = self.model(image_path, conf=self.confidence_threshold)
        objects = []
        
        for result in results:
            boxes = result.boxes
            for box in boxes:
                cls_id = int(box.cls[0])
                conf = float(box.conf[0])
                class_name = result.names[cls_id]
                objects.append({
                    "name": class_name,
                    "confidence": conf
                })
        return objects
