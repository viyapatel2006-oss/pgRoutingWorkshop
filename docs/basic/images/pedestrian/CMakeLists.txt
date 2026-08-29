
#---------------------
# Files
#---------------------
set(PGR_WORKSHOP_IMG_FILES
  pedestrian_combinations.png
  pedestrian_cost_many_to_many.png
  pedestrian_many_to_many.png
  pedestrian_one_to_many.png
  pedestrian_one_to_one.png
  stars.png
)


foreach (f ${PGR_WORKSHOP_IMG_FILES})
  if (PGR_WORKSHOP_VERBOSE_DEBUG)
    message(STATUS "      -> ${f}")
  endif()
  configure_file(${f} ${f} COPYONLY)
endforeach()
