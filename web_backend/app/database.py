from fastapi import Request
from neo4j import Driver, GraphDatabase


class Neo4jConnection:
    def __init__(self, uri, user, password):
        self._driver: Driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        if self._driver:
            self._driver.close()

    def get_session(self):
        return self._driver.session()


def get_db(request: Request):
    config = request.app.state.config
    uri = config.get("neo4j", "uri")
    user = config.get("neo4j", "user")
    password = config.get("neo4j", "password")
    conn = Neo4jConnection(uri, user, password)
    try:
        yield conn
    finally:
        conn.close()
