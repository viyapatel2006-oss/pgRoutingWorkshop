add_custom_target(un_sdg11_scripts)

configure_file(sdg11.sql  sdg11.sql)

add_custom_command(
  TARGET un_sdg11_scripts
  PRE_BUILD
  BYPRODUCTS
    exercise_1.txt
    exercise_2.txt
    exercise_3.txt
    exercise_4.txt
    exercise_5.txt
    exercise_6.txt
    exercise_7.txt
    exercise_8.txt
    exercise_9.txt
    exercise_10.txt
  COMMAND psql -d bangladesh -f sdg11.sql
  COMMENT "running sdg11 scripts"
)
