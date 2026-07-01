:file: This file is part of the pgRouting project.
:copyright: Copyright (c) 2021-2026 pgRouting developers
:license: Creative Commons Attribution-Share Alike 3.0 https://creativecommons.org/licenses/by-sa/3.0

Data for Sustainable Development Goals
###############################################################################

.. image:: ../basic/images/data/prepareData.png
  :align: center

To be able to use pgRouting, data has to be imported into a database. This chapter
will use ``osm2pgrouting`` to get the data from OpenStreetMap (OSM). This data will
be used for exercises in further chapters.

pgRouting is an extension which requires:

* Supported PostgreSQL version
* Supported PostGIS version

These requirements are met on OSGeoLive. When the required software is
installed, open a terminal window by pressing ``ctrl-alt-t`` and follow the
instructions. Information about installing OSGeoLive can be found in
:doc:`../appendix/osgeolive` of this workshop.

.. note:: If you don't have pgRouting installed. You can find the installation
  procedure at this `link
  <https://docs.pgrouting.org/latest/en/pgRouting-installation.html>`__

The database to install depends on the UN SDG chapter you are working on:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Chapter
     - Database
   * - :doc:`sdg3-health`
     - `Mumbai database`_
   * - :doc:`sdg7-energy`
     - `Mumbai database`_
   * - :doc:`sdg11-cities`
     - `Bangladesh database`_

.. contents:: Chapter Contents
   :depth: 2

Mumbai database
===============================================================================

.. contents:: Contents
   :local:

Create Mumbai database compatible with pgRouting
-------------------------------------------------------------------------------

Use the following command to create ``mumbai`` database

.. code-block::

        createdb mumbai

To connect to the database do the following

.. code-block::

        psql mumbai

After connecting to the database, the first step is to create ``EXTENSION`` to enable
pgRouting and PostGIS in the database. Then add the ``SCHEMA`` that are needed.

.. literalinclude:: ../scripts/get_data/setup_mumbai.sh
  :start-after: setup_mumbai from-here
  :end-before:  setup_mumbai to-here
  :language: postgresql
  :linenos:

Get the Mumbai Data
-------------------------------------------------------------------------------
The pgRouting workshop will make use of OpenStreetMap data of an area in Mumbai
City. The instructions for downloading the data are given below.

.. rubric:: Downloading Mumbai data from OSGeo

The following command is used to download the snapshot of the Mumbai area data
used in this workshop, using the download service of OSGeo.

.. note:: The Mumbai data for this workshop depends on this `snapshot
   <http://download.osgeo.org/pgrouting/workshops/mumbai.osm.bz2>`__.

.. literalinclude:: ../scripts/get_data/get_all_data.sh
    :start-after: mumbai data from-here
    :end-before:  mumbai data to-here
    :language: bash
    :linenos:

The following command was used in June 2021 to download the OpenStreetMap data
of the area in Mumbai, India.

.. code-block:: bash
    :linenos:

    CITY="mumbai"
    BBOX="72.8263,19.1021,72.8379,19.1166"
    wget --progress=dot:mega -O "$CITY.osm" "http://www.overpass-api.de/api/xapi?*[bbox=${BBOX}][@meta]"

Upload Mumbai data to the database
-------------------------------------------------------------------------------

The next step is to run ``osm2pgrouting`` converter, which is a command line
tool that inserts the data in the database, "ready" to be used with pgRouting.
See :doc:`../appendix/appendix-3` for additional information about ``osm2pgrouting``.

For this step the following is used:

* Configuration file: ``buildings.xml``
* Configuration file: the default ``mapconfig.xml`` provided with ``osm2pgrouting``

Copy the ``buildings.xml`` configuration file.

.. collapse:: buildings.xml

   .. literalinclude:: ../scripts/get_data/buildings.xml
      :language: xml

Importing Mumbai Roads
-------------------------------------------------------------------------------

The following ``osm2pgrouting`` command will be used to import the
``mumbai.osm`` roads into a pgRouting compatible database.

.. literalinclude:: ../scripts/get_data/setup_mumbai.sh
    :start-after: import_roads from-here
    :end-before: import_roads to-here
    :language: bash

.. collapse:: Output of the command

   .. literalinclude:: ../scripts/get_data/setup_mumbai.txt
      :start-after: import_roads from-here
      :end-before: import_roads to-here

Importing Mumbai Buildings
-------------------------------------------------------------------------------

The following ``osm2pgrouting`` command will be used to import the
``mumbai.osm`` buildings into a pgRouting compatible database.

.. literalinclude:: ../scripts/get_data/setup_mumbai.sh
    :start-after: import_buildings from-here
    :end-before: import_buildings to-here
    :language: bash

.. collapse:: Output of the command

   .. literalinclude:: ../scripts/get_data/setup_mumbai.txt
      :start-after: import_buildings from-here
      :end-before: import_buildings to-here

Compatibility with older osm2pgrouting versions (Mumbai)
-------------------------------------------------------------------------------

Check the installed version:

.. code-block:: bash

   osm2pgrouting --version

If you are using version 2.x, the column names differ from those used in this
workshop:

- ``gid`` instead of ``id``
- ``the_geom`` instead of ``geom``

Run the following script to rename them:

.. collapse:: Script

   .. literalinclude:: ../scripts/get_data/osm2pgrouting_compat_mumbai.sql
      :language: postgresql

Verify the data (Mumbai)
-------------------------------------------------------------------------------

To connect to the database, type the following in the terminal.

.. code-block:: bash

  psql mumbai

The importance of counting the information on this workshop is to make sure that
the same data is used and consequently the results are same.

.. literalinclude:: ../scripts/un_sdg/sdg3/sdg3.sql
   :start-after: count1.txt
   :end-before: count2.txt
   :language: sql

.. collapse:: Command output

  .. literalinclude:: ../scripts/un_sdg/sdg3/count1.txt

.. literalinclude:: ../scripts/un_sdg/sdg3/sdg3.sql
   :start-after: count2.txt
   :end-before: skip1.txt
   :language: sql

.. collapse:: Command output

  .. literalinclude:: ../scripts/un_sdg/sdg3/count2.txt

Continue with the workshop:

- :doc:`sdg3-health`
- :doc:`sdg7-energy`

Bangladesh database
===============================================================================

.. contents:: Contents
   :local:

Create Bangladesh area database compatible with pgRouting
-------------------------------------------------------------------------------

Use the following command to create ``bangladesh`` database

.. code-block::

        createdb bangladesh

To connect to the database do the following

.. code-block::

        psql bangladesh


After connecting to the database, the first step is to create ``EXTENSION`` to enable
pgRouting and PostGIS in the database. Then add the ``SCHEMA`` for each table.

.. literalinclude:: ../scripts/get_data/setup_bangladesh.sh
  :start-after: -- Commands inside the database
  :end-before:  -- create_bangladesh to-here
  :language: postgresql
  :linenos:

Get the Bangladesh Data
-------------------------------------------------------------------------------

.. rubric:: Downloading Bangladesh data from OSGeo

The following command is used to download the snapshot of the Bangladesh area data
used in this workshop, using the download service of OSGeo.

.. note:: The Bangladesh data for this workshop depends on this `snapshot
   <http://download.osgeo.org/pgrouting/workshops/bangladesh.osm.bz2>`__.

.. literalinclude:: ../scripts/get_data/get_all_data.sh
    :start-after: bangladesh data from-here
    :end-before:  bangladesh data to-here
    :language: bash
    :linenos:

The following command was used in June 2021 to download the OpenStreetMap data
of the area in Munshigang, Bangladesh.

.. code-block:: bash
    :linenos:

    CITY="bangladesh"
    BBOX="88.9515,22.2192,89.3806,22.4310"
    wget --progress=dot:mega -O "$CITY.osm" "http://www.overpass-api.de/api/xapi?*[bbox=${BBOX}][@meta]"

    osmconvert --drop-author --drop-version bangladesh.osm -o=bangladesh_pass1.osm
    osmfilter bangladesh_pass1.osm -o=bangladesh.osm --drop="highway= building="

Upload Bangladesh data to the database
-------------------------------------------------------------------------------

The next step is to run ``osm2pgrouting`` converter, which is a command line
tool that inserts the data in the database, "ready" to be used with pgRouting.
See :doc:`../appendix/appendix-3` for additional information about ``osm2pgrouting``.

For this step the following is used:

* Configuration file: ``waterways.xml``
* ``~/Desktop/workshop/bangladesh.osm`` - OSM data from the previous step
* ``bangladesh`` database

Copy the ``waterways.xml`` configuration file.

.. collapse:: waterways.xml

   .. literalinclude:: ../scripts/get_data/waterways.xml
      :language: xml

Importing Bangladesh Waterways
-------------------------------------------------------------------------------

The following ``osm2pgrouting`` command will be used to import the Waterways
from the OpenStreetMap file to the pgRouting database which we will use for further exercises.

.. literalinclude:: ../scripts/get_data/setup_bangladesh.sh
    :start-after: import_bangladesh_waterways from-here
    :end-before:  import_bangladesh_waterways to-here
    :language: bash

.. collapse:: Output of the command

   .. literalinclude:: ../scripts/get_data/setup_bangladesh.txt
      :start-after: import_bangladesh_waterways from-here
      :end-before: import_bangladesh_waterways to-here

Compatibility with older osm2pgrouting versions (Bangladesh)
-------------------------------------------------------------------------------

Check the installed version:

.. code-block:: bash

   osm2pgrouting --version

If you are using version 2.x, the column names differ from those used in this
workshop:

- ``gid`` instead of ``id``
- ``the_geom`` instead of ``geom``

Run the following script to rename them:

.. collapse:: Script

   .. literalinclude:: ../scripts/get_data/osm2pgrouting_compat_bangladesh.sql
      :language: postgresql

Verify the data (Bangladesh)
-------------------------------------------------------------------------------

To connect to the database, type the following in the terminal.

.. code-block:: bash

  psql bangladesh

Continue with the workshop:

- :doc:`sdg11-cities`
