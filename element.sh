PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [[ $# -eq 0 ]]
then
  echo "Please provide an element as an argument."
else
  FOUND=0
  while IFS="|" read TYPE_ID NUMBER SYMBOL ELEMENT MASS MELTING BOILING TYPE
  do
    if [[ $1 ==  $NUMBER || $1 == $ELEMENT || $1 == $SYMBOL ]]
    then
      echo "The element with atomic number $NUMBER is $ELEMENT ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $ELEMENT has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
      FOUND=1
      break
    fi
  done < <($PSQL "SELECT * FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id);")

  if [[ $FOUND -eq 0 ]]
  then
    echo "I could not find that element in the database."
  fi
fi