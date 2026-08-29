#!/bin/bash

set -e
echo "setup_bangladesh"

dropdb --if-exists bangladesh

# create_bangladesh from-here
# Create the database
createdb bangladesh

# login as user "user"
psql bangladesh << EOF

-- Commands inside the database
-- add pgRouting extension
CREATE EXTENSION pgrouting CASCADE;
CREATE EXTENSION hstore;

-- creating schemas for data
CREATE SCHEMA waterways;
-- create_bangladesh to-here

EOF

echo import_bangladesh_waterways from-here
@Osm2pgrouting_EXECUTABLE@ \
    -f "bangladesh.osm" \
    -c "waterways.xml" \
    --schema "waterways" \
    --tags \
    -d bangladesh \
    -U user \
    -W user \
    --clean
echo import_bangladesh_waterways to-here
