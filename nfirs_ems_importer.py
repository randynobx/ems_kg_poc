import logging
import os
import re
import sys
from configparser import ConfigParser

from neo4j import GraphDatabase


class NFIRSImporter:
    def __init__(self, config_file: str = 'config.ini'):
        config = ConfigParser()
        config.read(config_file)
        self.driver = GraphDatabase.driver(
            config.get('neo4j', 'uri'),
            auth=(
                config.get('neo4j', 'user'),
                config.get('neo4j', 'password')
            )
        )
        self.queries_dir = config.get('paths', 'queries_dir')

    def _load_cypher_query(self, query_name: str) -> str:
        """Load Cypher query from file."""
        query_path = os.path.join(self.queries_dir, f"{query_name}.cypher")
        with open(query_path, 'r') as f:
            return f.read()

    def import_lookup_codes(self):
        """Import all versioned lookup code CSV files."""
        lookup_dir = 'nfirs_lookup_codes'
        for filename in os.listdir(lookup_dir):
            if match := re.match(r"v(\d+\.\d+)\.csv", filename):
                version = match[1]
                csv_path = os.path.join(lookup_dir, filename)
                self._import_single_lookup_csv(csv_path, version)

    def _import_single_lookup_csv(self, csv_path: str, version: str):
        """Import a single versioned lookup code CSV."""
        query = """
        LOAD CSV WITH HEADERS FROM $csv_path AS row
        CALL apoc.merge.node(
          [row.type],
          {code: row.code, version: $version},
          {label: row.label},
          {}
        ) YIELD node
        RETURN count(node)
        """
        with self.driver.session() as session:
            session.run(query, csv_path=f"file:///{os.path.basename(csv_path)}", version=version)
            logging.info(f"Imported {csv_path} (version {version})")

    def import_ems_data(self, csv_file_path: str):
        """Import the main EMS CSV, linking to versioned code nodes."""
        query = self._load_cypher_query('load_ems_csv')
        with self.driver.session() as session:
            session.run(query, csv_path=f"file:///{os.path.basename(csv_file_path)}")
            logging.info(f"Imported main EMS data from {csv_file_path}")

    def close(self):
        self.driver.close()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    if len(sys.argv) != 2:
        print("Usage: python nfirs_ems_importer.py <main_csv_path>")
        sys.exit(1)
    main_csv_path = sys.argv[1]
    if not os.path.isfile(main_csv_path):
        print(f"File not found: {main_csv_path}")
        sys.exit(1)
    importer = NFIRSImporter('config.ini')
    try:
        importer.import_lookup_codes()
        importer.import_ems_data(main_csv_path)
    finally:
        importer.close()
