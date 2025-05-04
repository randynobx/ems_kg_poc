import asyncio
import os

from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile, status
from fastapi.responses import JSONResponse

from ..database import get_db
from ..utils.import_data import import_ems_csv
from ..utils.validation import validate_csv_file

router = APIRouter()


@router.post(
    "/",
    summary="Upload, validate, and import EMS CSV file into Neo4j",
    response_description="Status and details of the upload/import process"
)
async def upload_and_import_csv(
    request: Request,
    file: UploadFile = File(...),
    db=Depends(get_db)
):
    settings = request.app.state.config
    upload_dir = settings.upload_dir
    os.makedirs(upload_dir, exist_ok=True)
    file_location = os.path.join(upload_dir, file.filename)

    # Save the uploaded file
    try:
        with open(file_location, "wb") as f:
            content = await file.read()
            f.write(content)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save file: {e}"
        )

    # Validate the CSV
    if errors := validate_csv_file(file_location):
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={"status": "error", "errors": errors}
        )

    # Import into Neo4j
    cypher_path = os.path.join(settings.queries_dir, "load_ems_csv.cypher")
    try:
        # Offload blocking import to a thread
        result_summary = await asyncio.to_thread(
            import_ems_csv,
            file_location,
            db.get_session(),
            cypher_file=cypher_path
        )
        return {
            "status": "success",
            "message": "CSV validated and imported into Neo4j.",
            "filename": file.filename,
            "import_details": str(result_summary)
        }
    except FileNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Cypher query file not found: {e}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Neo4j import failed: {e}"
        )
