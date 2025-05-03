#!/bin/sh
# create_docker_secrets.sh

CONFIG_FILE="config.ini"
SECRETS_DIR="docker/secrets"

# Create secrets directory if it doesn't exist
mkdir -p "$SECRETS_DIR"

# Neo4j credentials (required)
if grep -q '\[neo4j\]' "$CONFIG_FILE"; then
  NEO4J_USER=$(awk -F= '/^user/ {print $2}' "$CONFIG_FILE" | tr -d '[:space:]' | sed 's/^'\''\(.*\)'\''$/\1/')
  NEO4J_PASSWORD=$(awk -F= '/^password/ {print $2}' "$CONFIG_FILE" | tr -d '[:space:]' | sed 's/^'\''\(.*\)'\''$/\1/')

  if [ -z "$NEO4J_PASSWORD" ]; then
    echo "Error: Neo4j password not found in config.ini"
    exit 1
  fi

  echo "$NEO4J_USER/$NEO4J_PASSWORD" > "$SECRETS_DIR/neo4j_auth.txt"
  chmod 600 "$SECRETS_DIR/neo4j_auth.txt"
  echo "Created Neo4j auth secret"
else
  echo "Error: [neo4j] section missing from config.ini"
  exit 1
fi