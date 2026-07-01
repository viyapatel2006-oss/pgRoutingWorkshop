add_custom_target(un_sdg7_scripts DEPENDS sdg7.sql)

configure_file(sdg7.sql sdg7.sql)

add_custom_command(
  TARGET un_sdg7_scripts
  PRE_BUILD
  BYPRODUCTS
    exercise_5.txt
    exercise_6.txt
    exercise_7.txt
    exercise_8.txt
    exercise_9.txt
    exercise_10.txt
    exercise_11.txt
    exercise_12.txt
  COMMAND psql -d mumbai -f sdg7.sql
  COMMENT "running chapter sdg7 scripts"
)
