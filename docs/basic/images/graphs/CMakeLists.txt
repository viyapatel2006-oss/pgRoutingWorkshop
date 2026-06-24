
#---------------------
# Files
#---------------------
set(PGR_WORKSHOP_IMG_FILES
  costMatrix.png
  pedestrian_only_roads.png
  qgis_credentials.png
  qgis_menu.png
  qgis_moveLayer.png
  roads_tag_ids.png
  taxi_net.png
  vehicle_net.png
  vertices_components.png
  vertices.png
  walk_net.png
  ways_components.png
)


foreach (f ${PGR_WORKSHOP_IMG_FILES})
  if (PGR_WORKSHOP_VERBOSE_DEBUG)
    message(STATUS "      -> ${f}")
  endif()
  configure_file(${f} ${f} COPYONLY)
endforeach()
