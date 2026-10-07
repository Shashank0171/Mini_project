import os
import shutil
from fastapi import APIRouter, UploadFile, File, HTTPException

from services.currency_service import CurrencyService

router = APIRouter(tags=["Currency"])
currency_service = CurrencyService()


@router.post("/currency")
async def detect_currency(file: UploadFile = File(...)):
    temp_file_path = None
    try:
        temp_file_path = f"temp_{file.filename}"
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        result = currency_service.detect_currency(temp_file_path)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)
