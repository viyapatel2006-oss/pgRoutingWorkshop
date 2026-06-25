add_custom_target(basic_vehicles_scripts)

#---------------------
# Files
#---------------------
configure_file(vehicles.sql vehicles.sql)

#----------------------------------------------
# Generating the results files
#---------------------------------------------

add_custom_command(
  TARGET basic_vehicles_scripts
  PRE_BUILD
  BYPRODUCTS
    oneway_cost.txt
    oneway_revc.txt
    route_going.txt
    route_coming.txt
    time_is_money.txt
    add_penalty.txt
    use_penalty.txt
    update_penalty.txt
    get_penalized_route.txt
    time_in_secs.txt
    penalized_view.txt
    using_view.txt
    vehicles_end.txt

  COMMAND psql -d city_routing -f vehicles.sql
  COMMENT "running vehicles scripts"
  DEPENDS vehicles.sql)
