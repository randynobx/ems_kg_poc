import configparser
from pathlib import Path


class Settings:
    def __init__(self, config_path: str = "config.ini"):
        self.neo4j_uri = None
        self.neo4j_user = None
        self.neo4j_password = None
        self.queries_dir = None
        self.upload_dir = None

        config_file = Path(config_path)
        if config_file.exists():
            self._load_from_ini(config_file)
        else:
            self._load_from_other_source()  # Placeholder for AWS or other secret manager

    def _load_from_ini(self, config_file: Path):
        config = configparser.ConfigParser()
        config.read(config_file)

        # Neo4j settings
        self.neo4j_uri = config.get("neo4j", "uri", fallback=None)
        self.neo4j_user = config.get("neo4j", "user", fallback=None)
        self.neo4j_password = config.get("neo4j", "password", fallback=None)

        # Paths
        self.queries_dir = config.get("paths", "queries_dir", fallback=None)
        self.upload_dir = config.get("paths", "upload_dir", fallback=None)

    def _load_from_other_source(self):
        raise NotImplementedError("No config.ini found and no alternative config source implemented.")

# Usage example:
# from .config import Settings
# settings = Settings()
# print(settings.neo4j_uri)
