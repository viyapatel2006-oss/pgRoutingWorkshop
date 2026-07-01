#!/bin/bash

set -e

# Create the database
createdb mumbai

# login as user "user"
psql mumbai << EOF

-- setup_mumbai from-here
-- add pgRouting extension
CREATE EXTENSION pgrouting CASCADE;

-- creating schemas for data
CREATE SCHEMA roads;
CREATE SCHEMA buildings;
CREATE EXTENSION hstore;
-- setup_mumbai to-here
EOF

echo import_roads from-here
@Osm2pgrouting_EXECUTABLE@ \
    -f "mumbai.osm" \
    -c "@Osm2pgrouting_mapconfig@" \
    --schema "roads" \
    -d mumbai \
    -U user \
    -W user \
    --tags \
    --clean
echo import_roads to-here

echo import_buildings from-here
@Osm2pgrouting_EXECUTABLE@ \
    -f "mumbai.osm" \
    -c "buildings.xml" \
    --schema "buildings" \
    --tags \
    -d mumbai \
    -U user \
    -W user \
    --clean
echo import_buildings to-here
