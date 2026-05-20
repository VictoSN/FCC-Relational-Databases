#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

get_valid_guess() {
  read USERS_GUESS
  while [[ ! $USERS_GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read USERS_GUESS
  done
}

echo "Enter your username:"
read USER_NAME

USER_ID=$($PSQL "SELECT user_id FROM guesser WHERE username = '$USER_NAME'")

if [[ -z $USER_ID ]]; then
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  $PSQL "INSERT INTO guesser(username, games_played, best_game) VALUES('$USER_NAME', 0, 0)" > /dev/null
  USER_ID=$($PSQL "SELECT user_id FROM guesser WHERE username='$USER_NAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM guesser WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM guesser WHERE user_id = $USER_ID")
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

$PSQL "UPDATE guesser SET games_played = games_played + 1 WHERE user_id = $USER_ID" > /dev/null

echo "Guess the secret number between 1 and 1000:"
get_valid_guess

NUMBER_OF_GUESSES=1
while [[ $USERS_GUESS -ne $RANDOM_NUMBER ]]; do
  if [[ $USERS_GUESS -gt $RANDOM_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  get_valid_guess
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

BEST_GAME=$($PSQL "SELECT best_game FROM guesser WHERE user_id=$USER_ID")
if [[ $BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
  $PSQL "UPDATE guesser SET best_game=$NUMBER_OF_GUESSES WHERE user_id=$USER_ID" > /dev/null
fi