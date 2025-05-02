from collections.abc import Generator

from neo4j import GraphDatabase

from .config import Settings

settings = Settings()

class Neo4jConnection:
    def __init__(self):
        self._driver = GraphDatabase.driver(
            settings.neo4j_uri,
            auth=(settings.neo4j_user, settings.neo4j_password)
        )

    def close(self):
        self._driver.close()

    def get_session(self):
        return self._driver.session()


def get_db() -> Generator:
    conn = Neo4jConnection()
    try:
        yield conn
    finally:
        conn.close()
