set -e

dropdb --if-exists city_routing
dropdb --if-exists bangladesh
dropdb --if-exists mumbai

# create city_routing

createdb city_routing

# connect city_routing

psql city_routing << EOF

CREATE EXTENSION pgrouting CASCADE;

-- Inspect the pgRouting installation
\dx+ pgrouting

-- View pgRouting version
SELECT pgr_full_version();

EOF

psql -c 'DROP ROLE IF EXISTS "user"; CREATE ROLE "user" SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN PASSWORD $$user$$;' -d city_routing

echo import city from-here
@Osm2pgrouting_EXECUTABLE@ \
    -f "@PGR_WORKSHOP_CITY_FILE@.osm" \
    -c "@Osm2pgrouting_mapconfig@" \
    -d city_routing \
    -U user \
    -W user \
    --clean
echo import city to-here
