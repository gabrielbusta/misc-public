# Restore shipit database from a sql dump

# STOP the non-database containers

CONTAINER="shipit-db-1"
DB_DUMP="shipitapi-20250213-212102.sql"
docker cp "$DB_DUMP" "$CONTAINER":/tmp/dumpfile.sql
docker exec -u root -it "$CONTAINER" /bin/bash

# In the container
psql -U shipituser -h localhost -d postgres
# In the psql shell
DROP DATABASE IF EXISTS shipitdb;
CREATE DATABASE shipitdb;
\q

psql -U shipituser -h localhost -d postgres
CREATE ROLE cloudsqladmin LOGIN;
CREATE ROLE cloudsqlsuperuser LOGIN;
CREATE ROLE shipitpublicprod LOGIN;
CREATE ROLE postgres LOGIN;
\q

psql -U shipituser -d shipitdb -f /tmp/dumpfile.sql

psql -U shipituser -h localhost -d shipitdb
GRANT USAGE ON SCHEMA public TO shipituserreadonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO shipituserreadonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO shipituserreadonly;
\q

# Start a nice shell for tinkering in the shipit-api container
docker exec -it shipit-api-1 /bin/bash
export FLASK_APP="shipit_api.admin.flask:app"
poetry run flask shell
