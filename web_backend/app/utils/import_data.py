import os
from typing import Optional

from neo4j import Session


def import_ems_csv(file_path: str, db_connection: Optional[
    Session], cypher_file: str = "queries/load_ems_csv.cypher") -> None:
    """
    Import EMS CSV data into Neo4j using a Cypher query loaded from file.
    :param file_path: Path to the CSV file (must be accessible to Neo4j in /import).
    :param db_connection: An open Neo4j session.
    :param cypher_file: Path to the Cypher query file.
    """
    if db_connection is None:
        raise ValueError("A valid Neo4j session is required.")

    # Load Cypher query from file
    if not os.path.isfile(cypher_file):
        raise FileNotFoundError(f"Cypher file not found: {cypher_file}")
    with open(cypher_file, "r", encoding="utf-8") as f:
        cypher_query = f.read()

    # Pass only the filename to Neo4j (it looks in its own /import directory)
    csv_filename = os.path.basename(file_path)
    db_connection.run(cypher_query, csv_path=f"file:///{csv_filename}")
