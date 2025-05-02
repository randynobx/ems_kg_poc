# EMS Knowledge Graph Prototype Architecture

## Overview

This project uses a containerized, modular architecture to manage and analyze NFIRS 5.0 EMS data as a Neo4j knowledge
graph. It is designed for robust data validation, versioned code lookups, and scalable bulk import.

---

## Components

- **Neo4j Database Container**
    - Stores the EMS knowledge graph.
    - Preloaded with versioned lookup codes.
    - Exposes Bolt and Browser ports.
    - Uses the APOC plugin for advanced Cypher operations.

- **Web Backend Container**
    - Python (FastAPI) app for:
        - CSV upload and validation
        - Batched Cypher import of validated data
    - Connects to Neo4j using the official driver.
    - Reads configuration from `config.ini`.

- **Shared Volumes**
    - `/import` directory for Neo4j: receives lookup and main CSVs.
    - `/app/uploads` for backend: stores uploaded files.

---

## Data Flow

1. **Lookup Codes**: Placed in `lookup_codes/vX.Y_lookup_codes.csv`, mounted to Neo4j `/import` and preloaded at
   startup.
2. **EMS Data Upload**: User uploads CSV via web backend, which saves to `/app/uploads` and validates format.
3. **Bulk Import**: Backend triggers Cypher import (from `queries/load_ems_csv.cypher`), loading data in batches into
   Neo4j.

---

## Deployment Diagram

```
+---------------------+          +---------------------+
|     web_backend     | <------> |      neo4j_db       |
|  (FastAPI, Python)  |  Bolt    |   (Neo4j, APOC)     |
+---------------------+          +---------------------+
         |   ^
         |   |  CSV upload (main EMS file)
         v   |
   /app/uploads (main CSV, user upload)
         |
         |  (copy/move for import)
         v
   /import (lookup codes, main CSV)
         |
         v
+---------------------+
|      neo4j_db       |
|   (Neo4j, APOC)     |
+---------------------+

```

---

## Configuration & Secrets Management

- **Local/Development:**
    - `config.ini` is used for all configuration (Neo4j URI, user, password, paths).
    - Never commit secrets to version control; add `config.ini` and `docker_secrets/` to `.gitignore`.

- **Production:**
    - If `config.ini` is absent, the backend loads credentials securely from AWS Secrets Manager (or another vault).
    - Docker Compose injects Neo4j credentials using Docker secrets (`NEO4J_AUTH_FILE`).
    - Backend can be extended to use Docker secrets or environment variables as well.

---

## Best Practices

- **Modular FastAPI structure:** Use routers for separation of upload/import and query endpoints.
- **Centralized config:** Use a single `Settings` class to load configuration from `config.ini` or secrets manager.
- **Secrets:** Use Docker secrets and/or AWS Secrets Manager for all credentials in production.
- **Validation:** All CSVs are validated before import; errors are returned to the user.
- **Bulk import:** Uses batched Cypher queries for efficient data loading.
- **Monitoring & Security:** Neo4j should be run with TLS enabled, and access restricted to backend and trusted clients.
---

## References

- [README.md](../README.md)
- [NFIRS 5.0 Reference Guide](https://www.usfa.fema.gov/downloads/pdf/nfirs/NFIRS_Complete_Reference_Guide_2015.pdf)
- [FastAPI Best Practices](https://fastapi.tiangolo.com/project-generation/) [1][5][7][9]
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) [6][8][10][12][14][16]