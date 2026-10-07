import os
import shutil
from fastapi import APIRouter, UploadFile, File, HTTPException

from services.scene_service import SceneService

router = APIRouter(tags=["Scene"])
scene_service = SceneService()

@router.post("/describe")
async def describe_scene(file: UploadFile = File(...)):
    temp_file_path = None
    try:
        temp_file_path = f"temp_{file.filename}"
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        description = scene_service.describe(temp_file_path)
        return {"description": description}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)
