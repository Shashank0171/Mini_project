import os
import shutil
from fastapi import APIRouter, UploadFile, File, HTTPException

from services.detection_service import DetectionService

router = APIRouter(tags=["Detection"])
detection_service = DetectionService()

@router.post("/detect")
async def detect_objects(file: UploadFile = File(...)):
    temp_file_path = None
    try:
        temp_file_path = f"temp_{file.filename}"
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        results = detection_service.detect(temp_file_path)
        return {"objects": results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)
