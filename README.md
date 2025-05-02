# NFIRS 5.0 EMS Module Knowledge Graph

This project provides a robust, future-proof Neo4j graph database schema for the NFIRS 5.0 EMS Module. It includes code lookup tables, a normalized main data model, and Cypher queries for efficient import and querying.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Setup & Import Instructions](#setup--import-instructions)
- [Knowledge Graph Schema](#knowledge-graph-schema)
- [Best Practices](#best-practices)
- [Sample Queries](#sample-queries)
- [References](#references)

---

## Overview

This repository enables the storage and analysis of EMS data from the National Fire Incident Reporting System (NFIRS) in a highly normalized, code-driven Neo4j graph database. All coded fields are linked to lookup nodes for clarity and analytics.

---

## Features

- **Normalized data model**: All coded fields reference lookup nodes (e.g., race, gender, procedures).
- **NFIRS-compliant**: Follows NFIRS 5.0 EMS documentation and codebooks.
- **Future-proof**: Only the Incident node stores the NFIRS version, making upgrades easy.
- **Efficient querying**: Supports powerful graph traversals for clinical, operational, and demographic analytics.

---

## Setup & Import Instructions

1. **Place all CSV files** in your Neo4j `import` directory.

2. **Load Lookup Tables**  
   Run the following Cypher script to load all code tables:
```
:source lookup_table_import.cypher
```

3. **Load Main EMS Data**  
Run the main data load script:
```
:source nfirs_ems_main_data_load.cypher
```

4. **Verify Data**  
Example:
```
MATCH (p:Patient)-[:HAS_RACE]->(rc:RaceCode)
RETURN p.id, rc.label LIMIT 10
```

---

## Knowledge Graph Schema

See [schema.md](schema.md) for a full, up-to-date schema description.

**Highlights:**
- All coded fields (e.g., race, gender, procedures) are linked to their respective code nodes.
- Injuries are modeled as nodes with relationships to both site and type codes.
- All temporal fields are stored as Neo4j `DATE` or `DATETIME` types.
- Only the `Incident` node stores the NFIRS version.

---

## Best Practices

- **Load code tables first.** All data nodes reference these lookup nodes.
- **Do not duplicate the `VERSION` property** on child nodes; store it only on the `Incident` node.
- **Use relationships** for all coded fields to maximize query flexibility and future-proofing.
- **Validate array pairs** (e.g., injury site/type) for alignment after import.

---

## Sample Queries

**Find all patients with a head injury:**
```
MATCH (p:Patient)-[:HAS_CLINICAL_DETAILS]->()-[:HAS_INJURY]->(inj)-[:HAS_SITE]->(site:InjurySiteCode {code: "1"})
RETURN p.id, site.label
```

**List all patients who received CPR:**
```
MATCH (p:Patient)-[:HAS_PROCEDURE]->(pc:ProcedureCode {code: "05"})
RETURN p.id, pc.label
```

**Get all incidents from a specific version:**
```
MATCH (i:Incident {version: "5.0"})
RETURN i.incident_key, i.inc_date
```

---

## References

- [NFIRS 5.0 Complete Reference Guide (FEMA/USFA)](https://www.usfa.fema.gov/downloads/pdf/nfirs/nfirs_complete_reference_guide_2015.pdf)
- [Neo4j Cypher Manual](https://neo4j.com/docs/cypher-manual/current/)
- [APX Data NFIRS Field Reference](https://apxdata.com/nfirs/)

---

**For questions or contributions, please open an issue or pull request.**