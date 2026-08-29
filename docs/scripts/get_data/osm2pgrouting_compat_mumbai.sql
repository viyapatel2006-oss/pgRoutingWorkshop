ALTER TABLE roads.ways RENAME COLUMN gid TO id;
ALTER TABLE roads.ways RENAME COLUMN the_geom TO geom;
ALTER TABLE buildings.ways RENAME COLUMN gid TO id;
ALTER TABLE buildings.ways RENAME COLUMN the_geom TO geom;
