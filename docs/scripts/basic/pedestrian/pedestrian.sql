
\o get_id.txt

SELECT osm_id, id FROM vertices
WHERE osm_id IN (@OSMID_1@, @OSMID_2@, @OSMID_3@, @OSMID_4@, @OSMID_5@)
ORDER BY osm_id;

\o stars.txt

CREATE OR REPLACE VIEW stars AS
SELECT id,
  CASE
    WHEN osm_id = @OSMID_1@ THEN '@PLACE_1@'
    WHEN osm_id = @OSMID_2@ THEN '@PLACE_2@'
    WHEN osm_id = @OSMID_3@ THEN '@PLACE_3@'
    WHEN osm_id = @OSMID_4@ THEN '@PLACE_4@'
    WHEN osm_id = @OSMID_5@ THEN '@PLACE_5@'
  END AS name,
  osm_id, geom
FROM vertices
WHERE osm_id IN (@OSMID_1@, @OSMID_2@, @OSMID_3@, @OSMID_4@, @OSMID_5@)
ORDER BY id;

SELECT id, name FROM stars;
\o one_to_one.txt

SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target,
    length AS cost
    FROM walk_net',
  @ID_1@,
  @ID_3@,
  directed := false);

\o one_to_one_view.txt

CREATE OR REPLACE VIEW pedestrian_one_to_one AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target,
    length AS cost
    FROM walk_net',
  @ID_1@,
  @ID_3@,
  directed := false)
)
SELECT dijkstra.*, geom FROM dijkstra
JOIN walk_net ON(edge = id)
ORDER BY  seq;

SELECT seq, path_seq, start_vid, end_vid, node, edge, cost, agg_cost
FROM pedestrian_one_to_one;

\o many_to_one.txt

CREATE OR REPLACE VIEW pedestrian_many_to_one AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target,
    length/1000 AS cost
    FROM walk_net',
  ARRAY[@ID_1@, @ID_2@],
  @ID_3@,
  directed := false)
)
SELECT dijkstra.*, geom FROM dijkstra
LEFT JOIN walk_net ON(edge = id)
ORDER BY  seq;

SELECT seq, path_seq, start_vid, end_vid, node, edge, cost, agg_cost
FROM pedestrian_many_to_one;

\o one_to_many.txt

CREATE OR REPLACE VIEW pedestrian_one_to_many AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target,
    cost
    FROM walk_net',
  @ID_3@,
  ARRAY[@ID_1@, @ID_2@],
  directed := false)
)
SELECT dijkstra.*, geom FROM dijkstra
LEFT JOIN walk_net ON(edge = id)
ORDER BY  seq;

SELECT seq, path_seq, start_vid, end_vid, node, edge, cost, agg_cost
FROM pedestrian_one_to_many;

\o many_to_many.txt

CREATE OR REPLACE VIEW pedestrian_many_to_many AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target,
    length / 1.3 / 60 AS cost
    FROM walk_net',
  ARRAY[@ID_1@, @ID_2@],
  ARRAY[@ID_3@, @ID_5@],
  directed := false)
)
SELECT dijkstra.*, geom FROM dijkstra
LEFT JOIN walk_net ON(edge = id)
ORDER BY  seq;

SELECT seq, path_seq, start_vid, end_vid, node, edge, cost, agg_cost
FROM pedestrian_many_to_many;

\o combinations.txt

CREATE OR REPLACE VIEW pedestrian_combinations AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target,
    length / 1.3 / 60 AS cost
    FROM walk_net',
  'SELECT * FROM (VALUES
    (@ID_1@, @ID_3@),
    (@ID_2@, @ID_5@))
  AS combinations (source, target)',
  directed := false)
)
SELECT dijkstra.*, geom FROM dijkstra
LEFT JOIN walk_net ON(edge = id)
ORDER BY  seq;

SELECT seq, path_seq, start_vid, end_vid, node, edge, cost, agg_cost
FROM pedestrian_combinations;

\o dijkstracost.txt

CREATE OR REPLACE VIEW pedestrian_cost_many_to_many AS
WITH dijkstra AS (
SELECT *
FROM pgr_dijkstraCost(
  'SELECT id, source, target,
    length / 1.3 / 60 AS cost
    FROM walk_net',
  ARRAY[@ID_1@, @ID_2@],
  ARRAY[@ID_3@, @ID_5@],
  directed := false)
)
SELECT row_number() over() AS id,
  start_vid, end_vid, agg_cost, ST_MakeLine(v1.geom, v2.geom) AS geom
FROM dijkstra
JOIN vertices AS v1 ON (start_vid = v1.id)
JOIN vertices AS v2 ON (end_vid = v2.id);

SELECT start_vid, end_vid, agg_cost
FROM pedestrian_cost_many_to_many;

\o note_1.txt
SELECT start_vid, end_vid, agg_cost
FROM pedestrian_many_to_many
WHERE edge = -1;
