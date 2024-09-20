#!/bin/bash
METHOD_MESSAGE(){
  if [[ -z $2 ]]
  then
   echo -e "\nWelcome, $1! It looks like this is your first time here.\n"
  else
   echo -e "\nWelcome back, $1! You have played $2 games, and your best game took $3 guesses.\n"
  fi 
}

PSQL="psql -X --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

echo "Enter your username:";

read USERNAME_ENTERED

USER_ID=$($PSQL "select user_id from users where username='$USERNAME_ENTERED'")

if [[ -z $USER_ID ]]
then 
  METHOD_MESSAGE $USERNAME_ENTERED
  IS_FIRST_TIME_USER=t
  INSERT_FIRST_TIME_USER=$($PSQL "insert into users(username) values('$USERNAME_ENTERED')")
  BEST_GAME=0
  TOTAL_GAMES_PLAYED=0
  USER_ID=$($PSQL "select user_id from users where username='$USERNAME_ENTERED'")
else
  IS_FIRST_TIME_USER=f
  BEST_GAME=$($PSQL "select best_game from users where user_id='$USER_ID'")
  TOTAL_GAMES_PLAYED=$($PSQL "select total_games from users where user_id='$USER_ID'")
  METHOD_MESSAGE $USERNAME_ENTERED $TOTAL_GAMES_PLAYED $BEST_GAME
fi
  
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "secret number is $SECRET_NUMBER"

echo "Guess the secret number between 1 and 1000:"

read GUESS_NUMBER;

while [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS_NUMBER;
done

NUMBER_OF_TRIES=1
while (( $SECRET_NUMBER != $GUESS_NUMBER ))
do
  if (( $GUESS_NUMBER > $SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS_NUMBER;
  while [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS_NUMBER;
  done
  (( NUMBER_OF_TRIES++ ))  
done

echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

if [[ $IS_FIRST_TIME_USER == t ]]
then
  UPDATE_USER_STATS=$($PSQL "update users set total_games = 1, best_game=$NUMBER_OF_TRIES where user_id ='$USER_ID'")
else
  NEW_TOTAL_GAMES=$TOTAL_GAMES_PLAYED+1;
  NEW_BEST_GAME=$NUMBER_OF_TRIES;
  if [[ $NUMBER_OF_TRIES > $BEST_GAME ]]
  then
     NEW_BEST_GAME=$BEST_GAME
  fi   
  UPDATE_USER_STATS=$($PSQL "update users set total_games = $NEW_TOTAL_GAMES, best_game=$NEW_BEST_GAME where user_id ='$USER_ID'")
fi    
