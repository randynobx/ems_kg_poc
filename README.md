# EMS 5.0 Knowledge Graph Prototype

A containerized, version-aware Neo4j knowledge graph for NFIRS 5.0 EMS data, with robust validation, secure secrets
management, and bulk import.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Directory Structure](#directory-structure)
- [Configuration](#configuration)
- [Setup & Usage](#setup--usage)
- [Scripts](#scripts)
- [Makefile Commands](#makefile-commands)
- [CSV Validation & Import](#csv-validation--import)
- [References](#references)

---

## Overview

This project enables scalable, standards-compliant management and analysis of EMS data from the National Fire Incident
Reporting System (NFIRS) 5.0. It features:

- A normalized Neo4j graph schema with versioned code lookups
- Automated CSV validation before import
- Bulk import using batched Cypher queries
- Modular, maintainable Docker-based deployment
- Secure secrets management using Docker secrets

---

## Architecture

See [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md) for a full system overview and deployment diagram.

**Key Components:**

- **Neo4j Database Container:** Stores the EMS knowledge graph, preloaded with lookup codes, supports APOC, and is
  secured with Docker secrets.
- **Web Backend Container:** Python (FastAPI) app for CSV upload, validation, and import.
- **Shared Volumes:** For CSV file transfer and data persistence.

---

## Directory Structure


```
ems-kg-poc/
├── Makefile
├── docker-compose.yml
├── docker-compose.dev.yml
├── docker-compose.prod.yml
├── docker/
│ └── secrets/
│ └── neo4j_auth.txt
├── scripts/
│ ├── create_docker_secrets.sh
│ └── validate_nfirs_csv.sh
├── config.ini # For local development only (not in prod)
├── queries/
│ └── load_ems_csv.cypher
├── lookup_codes/
│ └── v5.0_lookup_codes.csv
├── sample_data/
│ └── main.csv
├── web_backend/
│ ├── Dockerfile
│ └── app/
│ ├── init.py
│ ├── main.py
│ ├── config.py
│ ├── database.py
│ ├── api/
│ │ ├── init.py
│ │ ├── upload.py
│ │ └── query.py
│ └── utils/
│ ├── validation.py
│ └── import_data.py
└── doc/
└── ARCHITECTURE.md
```

---

## Configuration

- All service, path, and query settings are managed via `config.ini` at the project root (for development).
- **Production:** Uses Docker secrets for Neo4j credentials (`docker/secrets/neo4j_auth.txt`), not `config.ini`.
- Never commit `config.ini` or secret files to version control (see `.gitignore`).

**Example `config.ini`:**

```
[neo4j]
uri = bolt://neo4j_db:7687
user = neo4j
password = your_password

[paths]
data_dir = ./sample_data
queries_dir = ./queries
upload_dir = ./web_backend/app/uploads
```

---

## Setup & Usage

### **Local Development**

1. **Create and configure `config.ini`** (see above).
2. **Create Docker secrets for Neo4j:** `make secrets`
3. **Start the development environment:** `make dev`
4. **Access the web backend** at [http://localhost:8000](http://localhost:8000).
5. **Upload and validate your EMS CSV** via the `/upload/` endpoint.
6. **Import** validated data into Neo4j via the `/upload/import/` endpoint.
7. **Explore data** in Neo4j Browser at [http://localhost:7474](http://localhost:7474).

### **Production**

1. **Do NOT include `config.ini`**. Use Docker secrets for all credentials.
2. **Ensure `docker/secrets/neo4j_auth.txt`** is present and contains `neo4j/your_password`.
3. **Start the production environment:** `make prod`

---

## Scripts

All utility shell scripts are in the `scripts/` directory:

- `scripts/create_docker_secrets.sh`: Generates Docker secrets from `config.ini`.
- `scripts/validate_nfirs_csv.sh`: Validates a CSV file using the Python validation module.

---

## Makefile Commands

| Command             | Description                                        |
|---------------------|----------------------------------------------------|
| `make help`         | Show all available commands                        |
| `make dev`          | Start development environment with config.ini      |
| `make prod`         | Start production environment (uses Docker secrets) |
| `make validate-csv` | Validate a CSV file (set `CSV_FILE=path/to/file`)  |
| `make test`         | Run unit tests                                     |
| `make down`         | Stop and remove containers                         |
| `make clean`        | Remove containers, networks, and volumes           |
| `make prune`        | Full cleanup (containers, volumes, images, cache)  |
| `make secrets`      | Create Docker secrets from config.ini              |

**Example:**

```
make validate-csv CSV_FILE=sample_data/nfirs_all_incident_pdr_2023__ems.csv
```

---

## CSV Validation & Import

- **Validation** is performed using `web_backend/app/utils/validation.py` before any import.
- **Bulk import** uses the Cypher query in `queries/load_ems_csv.cypher`, loaded and executed by the backend.
- **Lookup codes** must be preloaded in the Neo4j `/import` directory (see `lookup_codes/`).

---

## References

- [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md)
- [NFIRS 5.0 Complete Reference Guide](https://www.usfa.fema.gov/downloads/pdf/nfirs/NFIRS_Complete_Reference_Guide_2015.pdf)
- [Neo4j Documentation](https://neo4j.com/docs/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Secrets Documentation](https://docs.docker.com/engine/swarm/secrets/)
