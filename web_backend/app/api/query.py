from fastapi import APIRouter, Depends, Request

from ..database import get_db

router = APIRouter()


@router.get("/patients", summary="List patients", tags=["Query"])
def list_patients(request: Request, db=Depends(get_db), limit: int = 10):
    """
    Example endpoint to list patients.
    """
    # Example Cypher query
    cypher = """
    MATCH (p:Patient)
    RETURN p.id AS patient_id
    LIMIT $limit
    """
    with db.get_session() as session:
        result = session.run(cypher, limit=limit)
        patients = [record["patient_id"] for record in result]
    return {"patients": patients}


# Add more query endpoints below as needed

# Example: Find incidents by date
@router.get("/incidents/by-date", summary="Find incidents by date", tags=["Query"])
def incidents_by_date(request: Request, db=Depends(get_db), date: str = None):
    """
    Example endpoint to find incidents by date (YYYY-MM-DD).
    """
    cypher = """
    MATCH (i:Incident)
    WHERE i.inc_date = date($date)
    RETURN i.incident_key AS incident_key, i.inc_date AS date
    LIMIT 100
    """
    with db.get_session() as session:
        result = session.run(cypher, date=date)
        incidents = [{"incident_key": r["incident_key"], "date": str(r["date"])} for r in result]
    return {"incidents": incidents}
