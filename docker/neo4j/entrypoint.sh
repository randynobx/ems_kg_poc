#!/bin/bash
set -e

# Set NEO4J_AUTH from Docker secret if present
if [ -f /run/secrets/neo4j_auth_file ]; then
  export NEO4J_AUTH=$(cat /run/secrets/neo4j_auth_file)
fi

# Import lookup codes or run any initialization logic here
if [ -f /import/lookup_codes.cypher ]; then
  echo "Importing lookup codes..."
  cypher-shell -u neo4j -p "$(echo "$NEO4J_AUTH" | cut -d'/' -f2)" -f /import/lookup_codes.cypher
fi

echo "Extension script complete."
