import os
from configparser import ConfigParser

from fastapi import FastAPI

from .api.query import router as query_router
from .api.upload import router as upload_router

# Load config.ini
config = ConfigParser()
config.read(os.getenv("CONFIG_PATH", "/app/config.ini"))

app = FastAPI(
    title="EMS Knowledge Graph API",
    description="Upload, validate, import, and query EMS CSV data in Neo4j."
)

# Make config accessible to routers
app.state.config = config

# from .api.query import router as query_router  # For future endpoints

app.include_router(upload_router, prefix="/upload", tags=["Upload & Import"])
app.include_router(query_router, prefix="/query", tags=["Query"])


@app.get("/health", summary="Health check endpoint")
def health():
    return {"status": "ok"}
