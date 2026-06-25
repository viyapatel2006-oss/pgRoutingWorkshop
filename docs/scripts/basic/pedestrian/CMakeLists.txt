#---------------------
# Files
#---------------------
add_custom_target(basic_pedestrian_scripts)

configure_file(pedestrian.sql pedestrian.sql)
configure_file(images.sql images.sql)

#----------------------------------------------
# Generating the results files
#---------------------------------------------

add_custom_command(
  TARGET basic_pedestrian_scripts
  PRE_BUILD
  BYPRODUCTS
    combinations.txt
    get_id.txt
    many_to_many.txt
    many_to_one.txt
    note_1.txt
    one_to_many.txt
    one_to_one.txt
    dijkstracost.txt
    stars.txt

  COMMAND psql -d city_routing -f pedestrian.sql
  COMMAND psql -d city_routing -f images.sql
  COMMENT "running chapter pedestrian scripts"
  DEPENDS pedestrian.sql images.sql)
