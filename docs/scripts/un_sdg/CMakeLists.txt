add_custom_target(un_sdg_scripts ALL)

set(PGR_WORKSHOP_SUBDIRS
  sdg3
  sdg7
  sdg11
  )

foreach (dir ${PGR_WORKSHOP_SUBDIRS})
  if (PGR_WORKSHOP_DEBUG)
    message(STATUS "   Adding directory ${dir}")
  endif()
  add_subdirectory(${dir})
  add_dependencies(un_sdg_scripts un_${dir}_scripts)
endforeach()
