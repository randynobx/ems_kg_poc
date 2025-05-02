# Web Backend for EMS Knowledge Graph

This is the FastAPI-based web backend for the EMS 5.0 Knowledge Graph project. It provides endpoints for:

- Uploading and validating NFIRS 5.0 EMS CSV files
- Importing validated data into Neo4j
- (Planned) Querying the Neo4j knowledge graph

## Features

- **CSV Upload & Validation:** Ensures data quality before import.
- **Bulk Import:** Efficiently loads large datasets into Neo4j using batched Cypher queries.
- **Modular API:** Easily extendable for new endpoints and queries.
- **Configuration:** Reads settings from `config.ini` (for development) or a secrets manager (for production).

## Directory Structure

```
web_backend/
├── README.md
├── pyproject.toml
├── poetry.lock
├── Dockerfile
└── app/
├── init.py
├── main.py
├── config.py
├── database.py
├── api/
│ ├── init.py
│ ├── upload.py
│ └── query.py
└── utils/
├── validation.py
└── import_data.py
```

## Development

1. **Install dependencies:**
    ```
    poetry install
    ```

2. **Run the FastAPI app:**
    ```
    poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
    ```

3. **Configuration:**
    - Place a `config.ini` in the project root (see the main repo README for format).

## Docker Usage

- The backend is built and run as part of the main project’s Docker Compose setup.
- For local development, ensure `config.ini` is mounted into the container.

## Testing

Run tests (if present) with: `poetry run pytest`

## License

See the main repository for license and contribution guidelines.