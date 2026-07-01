DROP TABLE IF EXISTS buildings;
DROP TABLE IF EXISTS roads_net;
\o kind_of_buildings.txt

SELECT DISTINCT tag_id, tag_value
FROM buildings.ways JOIN buildings.configuration USING (tag_id)
ORDER BY tag_id;

\o population_function.txt

CREATE OR REPLACE FUNCTION  population(tag_id INTEGER, area INTEGER)
RETURNS INTEGER AS
$BODY$
DECLARE
population INTEGER;
BEGIN
  IF tag_id <= 100 THEN population = 1; -- Negligible
  ELSIF 100 < tag_id AND tag_id <= 200 THEN  population = GREATEST(2, area * 0.0002); -- Very Sparse
  ELSIF 200 < tag_id AND tag_id <= 300 THEN  population = GREATEST(3, area * 0.002); -- Sparse
  ELSIF 300 < tag_id AND tag_id <= 400 THEN population = GREATEST(5,  area * 0.05); -- Moderate
  ELSIF 400 < tag_id AND tag_id <= 500  THEN population = GREATEST(7, area * 0.7); -- Dense
  ELSIF tag_id > 500  THEN population = GREATEST(10,area * 1); -- Very Dense
  ELSE population = 1;
  END IF;
  RETURN population;
END;
$BODY$
LANGUAGE plpgsql;

\o show_population_100.txt
SELECT tag_id, tag_value, population(tag_id, 100)
FROM buildings.configuration
ORDER BY tag_id;
\o show_population_300.txt
SELECT tag_id, tag_value, population(tag_id, 300)
FROM buildings.configuration
ORDER BY tag_id;
\o show_schemas.txt
\dn
\o show_path1.txt
SHOW search_path;
\o set_path.txt
SET search_path TO public,roads,buildings,contrib,postgis;
\o show_path2.txt
SHOW search_path;
\o enumerate_tables.txt
\dt
\o count1.txt
SELECT COUNT(*) FROM roads.ways;
\o count2.txt
SELECT COUNT(*) FROM buildings.ways;
\o skip1.txt


\o only_connected0.txt

ALTER TABLE roads.ways ADD COLUMN component BIGINT;

\o only_connected1.txt

SELECT id, in_edges, out_edges, x, y, NULL::BIGINT osm_id, NULL::BIGINT component, geom
INTO vertices
FROM pgr_extractVertices('SELECT id, source, target FROM roads.ways ORDER BY id');

\o only_connected2.txt

WITH
get_data as (
  SELECT source, source_osm, ST_startPoint(geom) as pt FROM roads.ways
  UNION ALL
  SELECT target, target_osm, ST_endPoint(geom) FROM roads.ways
)
UPDATE vertices SET
(geom, osm_id, x, y) = (ST_startPoint(pt), source_osm, st_x(pt), st_y(pt))
FROM get_data WHERE source = id;

\o only_connected3.txt

UPDATE vertices SET component = c.component
FROM (
  SELECT * FROM pgr_connectedComponents(
  'SELECT id, source, target, cost, reverse_cost FROM roads.ways')
) AS c
WHERE id = node;


\o only_connected4.txt

UPDATE roads.ways SET component = v.component
FROM (SELECT id, component FROM vertices) AS v
WHERE source = v.id;

\o only_connected5.txt

-- DROP TABLE IF EXISTS roads_net;
CREATE TABLE roads_net AS

WITH
all_components AS (SELECT component, count(*) FROM roads.ways GROUP BY component),
max_component AS (SELECT max(count) from all_components),
the_component AS (
  SELECT component FROM all_components
  WHERE count = (SELECT max FROM max_component))

SELECT
  w.id, source, target,
  length_m/60 AS cost, length_m/60 AS reverse_cost,
  name, length_m AS length, NULL::BIGINT population, tag_id, component, geom AS geom
FROM roads.ways w JOIN the_component USING (component);

\o only_connected6.txt

DELETE FROM vertices WHERE component != (SELECT DISTINCT component FROM roads_net LIMIT 1);

\o building_road.txt
CREATE OR REPLACE FUNCTION building_road(building GEOMETRY)
RETURNS BIGINT AS
$BODY$
  SELECT id FROM roads_net ORDER BY geom <-> $1 LIMIT 1;
$BODY$
LANGUAGE SQL;

\o test_building_road.txt

SELECT id, building_road(geom) FROM buildings.ways LIMIT 3;

\o nearest_vertex.txt

CREATE OR REPLACE FUNCTION get_vertex(geom GEOMETRY)
RETURNS BIGINT AS
$BODY$
SELECT id FROM vertices ORDER BY geom <-> $1 LIMIT 1;
$BODY$
LANGUAGE SQL;

\o test_nearest_vertex.txt

SELECT get_vertex(geom) FROM buildings.ways LIMIT 3;

\o clean_buildings.txt
-- DROP TABLE IF EXISTS buildings;
CREATE TABLE buildings AS
WITH
buildings_data AS (
SELECT id, name, building_road(geom) AS road, get_vertex(geom) AS vid, tag_id, geom, ST_MakePolygon(geom) AS building
FROM buildings.ways
WHERE ST_NumPoints(geom) >= 4
  AND ST_IsClosed(geom) = TRUE)
SELECT id, name,
  ST_Area(building::geography)::INTEGER AS area,
  population(tag_id, ST_Area(building::geography)::INTEGER) AS population,
  road, vid,
  tag_id,
  geom, building
FROM buildings_data;

\o roads_population.txt

UPDATE roads_net SET population = SUM
FROM (
  SELECT road, SUM(population)
  FROM buildings GROUP BY road
  )
AS subquery
WHERE id = road;

\o served_roads.txt

SELECT id, source, target, agg_cost AS minutes, geom
FROM pgr_drivingDistance(
  'SELECT * FROM roads_net',
  (
    -- the starting vertex
    SELECT vid
    FROM buildings
    WHERE tag_id = '318'
  ),
  10,  -- 10 minutes
  false -- graph is undirected
) AS results
JOIN roads_net ON (edge = id);

\o adjacent_roads.txt

WITH
subquery AS (
  SELECT edge, source, target, agg_cost AS minutes, geom
  FROM pgr_drivingDistance(
    'SELECT * FROM roads_net',
    (
      SELECT vid
      FROM buildings
      WHERE tag_id = '318'
    ), 10, FALSE
  ) AS results
  JOIN roads_net AS r ON (edge = id)
),
connected_edges AS (
  SELECT r.id, r.source, r.target, length, r.geom
  FROM subquery AS s JOIN roads_net AS r
  ON ((s.source = r.source OR s.source = r.target))
)
SELECT * FROM subquery
UNION ALL
SELECT * FROM connected_edges;

\o population_served.txt

WITH
subquery AS (
  SELECT source, target
  FROM pgr_drivingDistance(
    'SELECT * FROM roads_net',
    (
      SELECT vid
      FROM buildings
      WHERE tag_id = '318'
    ), 10, FALSE
  )
  AS results
  JOIN roads_net AS r ON (edge = id)
),
connected_edges AS (
  SELECT DISTINCT id, population
  FROM subquery AS s JOIN roads_net AS r
  ON (
    (s.source = r.source OR s.source = r.target) OR
    (s.target = r.source OR s.target = r.target)
  )
)
SELECT SUM(population) FROM connected_edges;
