# EMS 5.0 Knowledge Graph Prototype

A containerized, version-aware Neo4j knowledge graph for NFIRS 5.0 EMS data, with robust validation and bulk import.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Directory Structure](#directory-structure)
- [Configuration](#configuration)
- [Setup & Usage](#setup--usage)
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

---

## Architecture

See [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md) for a full system overview and deployment diagram.

**Key Components:**

- **Neo4j Database Container:** Stores the EMS knowledge graph, preloaded with lookup codes, supports APOC.
- **Web Backend Container:** Python (FastAPI) app for CSV upload, validation, and import.
- **Shared Volumes:** For CSV file transfer and data persistence.

---

## Directory Structure

```
ems-kg-poc/
├── docker/
│ └── neo4j/
│ └── entrypoint.sh
├── web_backend/
│ ├── app/
│ │ ├── init.py
│ │ ├── main.py
│ │ ├── database.py
│ │ └── utils/
│ │ ├── validation.py
│ │ └── import_data.py
│ ├── Dockerfile
│ └── pyproject.toml
├── queries/
│ └── load_ems_csv.cypher
├── lookup_codes/
│ └── v5.0_lookup_codes.csv
├── sample_data/
│ └── main.csv
├── docker-compose.yml
├── config.ini
├── .gitignore
├── .dockerignore
├── README.md
└── doc/
└── ARCHITECTURE.md
```

---

## Configuration

All service, path, and query settings are managed via `config.ini` at the project root.

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

1. **Configure** your settings in `config.ini`.
2. **Build and start** the stack with Docker Compose: `docker-compose up --build`
3. **Access the web backend** at [http://localhost:8000](http://localhost:8000) (default FastAPI port).
4. **Upload your EMS CSV** via the `/upload/` endpoint.
5. **Validate**: The backend will return validation results.
6. **Import**: Use the `/import/` endpoint to load validated data into Neo4j.
7. **Explore data** in Neo4j Browser at [http://localhost:7474](http://localhost:7474).

---

## CSV Validation & Import

- **Validation** is performed using `web_backend/app/utils/validation.py` before any import.
- **Bulk import** uses the Cypher query in `queries/load_ems_csv.cypher`, loaded and executed by the backend.
- **Lookup codes** must be preloaded in the Neo4j `/import` directory (see `lookup_codes/`).

---

## References

- [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md)
- [doc/SCHEMA.md](doc/SCHEMA.md)
- [NFIRS 5.0 Complete Reference Guide](https://www.usfa.fema.gov/downloads/pdf/nfirs/NFIRS_Complete_Reference_Guide_2015.pdf)
- [Neo4j Documentation](https://neo4j.com/docs/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
