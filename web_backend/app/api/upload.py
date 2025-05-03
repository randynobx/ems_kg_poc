import os

from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile
from fastapi.responses import JSONResponse

from ..database import get_db
from ..utils.import_data import import_ems_csv
from ..utils.validation import validate_csv_file

router = APIRouter()


@router.post("/", summary="Upload and validate EMS CSV file")
async def upload_csv(request: Request, file: UploadFile = File(...)):
    settings = request.app.state.config
    upload_dir = settings.upload_dir
    os.makedirs(upload_dir, exist_ok=True)
    file_location = os.path.join(upload_dir, file.filename)
    with open(file_location, "wb") as f:
        content = await file.read()
        f.write(content)

    errors = validate_csv_file(file_location)
    if errors:
        return JSONResponse(
            status_code=400,
            content={"status": "error", "errors": errors}
        )
    return {"status": "success", "message": "CSV file validated successfully.", "filename": file.filename}


@router.post("/import/", summary="Import validated EMS CSV into Neo4j")
def import_csv(request: Request, filename: str, db=Depends(get_db)):
    settings = request.app.state.config
    file_location = os.path.join(settings.upload_dir, filename)
    if not os.path.isfile(file_location):
        raise HTTPException(status_code=404, detail="File not found")
    try:
        cypher_path = os.path.join(settings.queries_dir, "load_ems_csv.cypher")
        import_ems_csv(file_location, db.get_session(), cypher_file=cypher_path)
        return {"status": "success", "message": "CSV imported into Neo4j."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Import failed: {str(e)}") from e
