\o oneway_cost.txt

SELECT count(*) FROM vehicle_net
WHERE cost < 0;

\o oneway_revc.txt


SELECT count(*) FROM vehicle_net
WHERE reverse_cost < 0;


\o route_going.txt

CREATE OR REPLACE VIEW vehicle_route_going AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target, cost, reverse_cost
   FROM vehicle_net',
  @ID_1@, @ID_5@,
  directed := true)
)
SELECT dijkstra.*, geom
FROM dijkstra
LEFT JOIN vehicle_net ON(edge = id);

SELECT seq, start_vid, end_vid, node, edge, cost, agg_cost
FROM vehicle_route_going;
\o route_coming.txt

CREATE OR REPLACE VIEW vehicle_route_coming AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target, cost, reverse_cost
  FROM vehicle_net',
  @ID_5@, @ID_1@,
  directed := true)
)
SELECT dijkstra.*, geom
FROM dijkstra
LEFT JOIN vehicle_net ON(edge = id);

SELECT seq, start_vid, end_vid, node, edge, cost, agg_cost
FROM vehicle_route_coming;

\o time_is_money.txt

CREATE OR REPLACE VIEW vehicle_time_is_money AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra(
  'SELECT id, source, target,
    cost / 3600 * 100 AS cost,
    reverse_cost / 3600 * 100 AS reverse_cost
   FROM vehicle_net',
  @ID_5@, @ID_1@)
)
SELECT dijkstra.*, geom
FROM dijkstra
LEFT JOIN vehicle_net ON(edge = id);

SELECT seq, start_vid, end_vid, node, edge, cost, agg_cost
FROM vehicle_time_is_money;

\o add_penalty.txt

ALTER TABLE configuration
  ADD COLUMN IF NOT EXISTS penalty FLOAT DEFAULT 1.0;
UPDATE configuration SET penalty = 1.0;

\o create_penalized_view.txt

CREATE OR REPLACE VIEW vehicle_penalized_net AS
SELECT v.id, source, target,
  CASE WHEN cost <= 0 THEN -1 ELSE cost * penalty END AS cost,
  CASE WHEN reverse_cost <= 0 THEN -1 ELSE reverse_cost * penalty END AS reverse_cost,
  name, length, penalty, geom
FROM vehicle_net v
JOIN configuration c USING(tag_id)
ORDER BY id;

\o use_penalty.txt

CREATE OR REPLACE VIEW vehicle_penalized_route AS
WITH dijkstra AS (
SELECT * FROM pgr_dijkstra(
  'SELECT * FROM vehicle_penalized_net',
   @ID_5@, @ID_1@)
)
SELECT dijkstra.*, penalty, geom
FROM dijkstra
LEFT JOIN vehicle_penalized_net ON(edge = id);

SELECT seq, start_vid, end_vid, node, edge, cost, agg_cost, penalty
FROM vehicle_penalized_route;
\o same_result_as_comming.txt
SELECT * FROM vehicle_route_coming
WHERE edge = -1;
SELECT * FROM vehicle_penalized_route
WHERE edge = -1;

\o update_penalty.txt

-- Not including cycleways
UPDATE configuration SET penalty=-1.0
WHERE tag_key IN ('cycleway') OR tag_value IN ('cycleway');

-- Penalizing with 5 times the costs the unknown
UPDATE configuration SET penalty=5 WHERE tag_value IN ('unclassified');

-- Encuraging the use of "fast" roads
UPDATE configuration SET penalty=0.5 WHERE tag_value IN ('tertiary');
UPDATE configuration SET penalty=0.3
WHERE tag_value IN (
    'primary','primary_link',
    'trunk','trunk_link',
    'motorway','motorway_junction','motorway_link',
    'secondary');

\o show_penalties.txt

SELECT tag_id, tag_key,  tag_value, penalty
FROM configuration ORDER BY tag_id;

\o get_penalized_route.txt

SELECT seq, start_vid, end_vid, node, edge, cost, agg_cost, penalty
FROM vehicle_penalized_route;

\o time_in_secs.txt

SELECT * FROM pgr_dijkstra(
  $$
  SELECT id, source, target, cost, reverse_cost
  FROM (
    -- Nested call
    SELECT edge AS id FROM pgr_dijkstra(
      'SELECT * FROM vehicle_penalized_net',
      @ID_5@, @ID_1@) ) AS edges_in_route
  JOIN vehicle_net USING (id)
  $$,
  @ID_5@, @ID_1@);

\o vehicles_end.txt
\o
