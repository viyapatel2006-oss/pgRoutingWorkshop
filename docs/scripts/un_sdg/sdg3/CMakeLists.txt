add_custom_target(un_sdg3_scripts)

configure_file(sdg3.sql sdg3.sql)

add_custom_command(
  TARGET un_sdg3_scripts
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
    exercise_13.txt
    exercise_14.txt
    exercise_15.txt
    exercise_16.txt
    exercise_17.txt
    exercise_18.txt
    exercise_19.txt
    exercise_20.txt
  COMMAND psql -d mumbai -f sdg3.sql
  COMMENT "running chapter sdg3 scripts"
)
