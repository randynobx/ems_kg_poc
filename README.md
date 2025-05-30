# EMS 5.0 Knowledge Graph Prototype

A containerized, version-aware Neo4j knowledge graph for NFIRS 5.0 EMS data, with robust validation, secure secrets
management, and bulk import.

---

## Overview

This project enables scalable, standards-compliant management and analysis of EMS data from the National Fire Incident
Reporting System (NFIRS) 5.0. It features:

- A normalized Neo4j graph schema with versioned code lookups
- Automated CSV validation and bulk import
- Modular, maintainable Docker-based deployment
- Secure secrets management using Docker secrets

---

## Project Structure


```
ems-kg-poc/
├── Makefile
├── docker/
│ └── compose/ 
│   ├── base.yml
│   ├── dev.yml
│   ├── prod.yml
│ └── secrets/
├── scripts/
├── config.ini # For local development only
├── queries/
├── nfirs_lookup_codes/
├── sample_data/
├── web_backend/ # See web_backend/README.md for details
└── docs/
  └── ARCHITECTURE.md
  └── SCHEMA.md
```

---

## Quick Start

### Local Development

1. **Configure `config.ini`**

```
[neo4j]
uri = bolt://neo4j-db:7687
user = neo4j
password = your_password

[paths]
queries_dir = /queries
upload_dir = /app/uploads
```
2. **Create Docker secrets:** `make secrets`
3. **Start the development environment:** `make dev`

### Production

1. **Use Docker secrets for Neo4j credentials.**
2. **Start the production environment:** `make prod`

---

## Docker Compose Files

All Docker Compose files are now in `./docker/compose/`:

- `base.yaml` – Base configuration (all environments)
- `dev.yaml` – Development overrides (mounts config.ini, etc.)
- `prod.yaml` – Production overrides (uses Docker secrets)

### Makefile Commands

| Command             | Description                                        |
|---------------------|----------------------------------------------------|
| `make dev`          | Start development environment (with config.ini)    |
| `make prod`         | Start production environment (uses Docker secrets) |
| `make down`         | Stop and remove containers                         |
| `make clean`        | Remove containers, networks, and volumes           |
| `make prune`        | Full Docker cleanup                                |
| `make secrets`      | Create Docker secrets from config.ini              |
| `make validate-csv` | Validate a CSV file (set `CSV_FILE=path/to/file`)  |
| `make test`         | Run unit tests                                     |

**Example usage:**
```
make dev
make prod
make validate-csv CSV_FILE=sample_data/main.csv
```

### Notes

- All Docker Compose commands are routed through the Makefile, so you never need to type out the full
  `-f ./docker/compose/...` paths.
- Update any scripts or documentation to reference the new compose file locations if they previously used files in the
  project root.

---

## Documentation

- **Backend API, validation, and import:** [web_backend/README.md](web_backend/app/README.md)
- **Architecture and deployment:** [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md)

---

## References

- [NFIRS 5.0 Complete Reference Guide](https://www.usfa.fema.gov/downloads/pdf/nfirs/NFIRS_Complete_Reference_Guide_2015.pdf)
- [Neo4j Documentation](https://neo4j.com/docs/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Secrets Documentation](https://docs.docker.com/engine/swarm/secrets/)
