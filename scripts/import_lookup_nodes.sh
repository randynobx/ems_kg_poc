#!/bin/bash
set -e

# Read credentials from Docker secret
NEO4J_AUTH=$(cat /run/secrets/neo4j_auth_file)
NEO4J_USER=$(echo "$NEO4J_AUTH" | cut -d'/' -f1)
NEO4J_PASSWORD=$(echo "$NEO4J_AUTH" | cut -d'/' -f2)

echo "Creating constraints."
cypher-shell -a "bolt://neo4j-db:7687" -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" <<-EOC
    CREATE CONSTRAINT incident_unique IF NOT EXISTS FOR (i:Incident) REQUIRE i.incident_key IS UNIQUE;
    CREATE CONSTRAINT patient_unique IF NOT EXISTS FOR (p:Patient) REQUIRE p.id IS UNIQUE;
    CREATE CONSTRAINT race_code_unique IF NOT EXISTS FOR (rc:RaceCode) REQUIRE (rc.code, rc.version) IS UNIQUE;
    CREATE CONSTRAINT ethnicity_code_unique IF NOT EXISTS FOR (ec:EthnicityCode) REQUIRE (ec.code, ec.version) IS UNIQUE;
    CREATE CONSTRAINT gender_code_unique IF NOT EXISTS FOR (gc:GenderCode) REQUIRE (gc.code, gc.version) IS UNIQUE;
EOC

# Load all versioned lookup code CSVs
echo "Importing lookup codes..."

for csv_file in /import/nfirs_lookup_codes/v*_lookup_codes.csv; do
  if [ -f "$csv_file" ]; then
    # Extract version from filename (e.g., v5.0 from v5.0_lookup_codes.csv)
    version=$(basename "$csv_file" | grep -oP 'v\d+\.\d+')

    # Cypher query to load CSV and create nodes with version property
    cypher-shell -a "bolt://neo4j-db:7687" -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" <<-EOC
      LOAD CSV WITH HEADERS FROM 'file:///nfirs_lookup_codes/$(basename "$csv_file")' AS row
      CALL apoc.merge.node(
        [row.type],
        {code: row.code, version: "$version"},
        {description: row.description}
      ) YIELD node
      RETURN count(node)
EOC
  echo "Loaded $csv_file"
  fi
done

echo "Lookup code import completed."
