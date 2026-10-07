import os
import torch
from PIL import Image
from transformers import BlipProcessor, BlipForConditionalGeneration
from dotenv import load_dotenv

load_dotenv()

class SceneService:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SceneService, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        self.model_name = os.getenv("SCENE_MODEL_NAME", "Salesforce/blip-image-captioning-base")
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        
        try:
            print(f"Loading BLIP model on {self.device}...")
            self.processor = BlipProcessor.from_pretrained(self.model_name)
            self.model = BlipForConditionalGeneration.from_pretrained(self.model_name).to(self.device)
        except Exception as e:
            print(f"Error initializing BLIP model: {e}")
            self.model = None
            self.processor = None

    def describe(self, image_path):
        if self.model is None or self.processor is None:
            return "Scene description model is unavailable."
            
        try:
            raw_image = Image.open(image_path).convert('RGB')
            inputs = self.processor(raw_image, return_tensors="pt").to(self.device)
            out = self.model.generate(**inputs)
            caption = self.processor.decode(out[0], skip_special_tokens=True)
            return caption
        except Exception as e:
            print(f"Error generating description: {e}")
            return "Error generating description."
