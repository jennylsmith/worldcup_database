#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
WORKSPACE_DIR="/workspace/project"
INFILE="$WORKSPACE_DIR/games.csv"

# function to return a list of unique team names
ALL_NAMES () {
    $PSQL "SELECT DISTINCT(name) FROM teams;"
}

# clear the data 
echo $($PSQL "TRUNCATE teams,games;")

##### insert team names
cat $INFILE | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
# head -1 games.csv | tr "," " " | tr '[:lower:]' '[:upper:]'
do
  # how to make this recursive? use case statement?
  if [[ $WINNER != "winner" ]]
  then  
    # query unique team names
    NAMES=$(ALL_NAMES)

    # if empty, add first winner team name
    if [[ -z $NAMES ]]
    then
      INSERT_NAMES=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # NAMES=$WINNER # update NAMES variable with bash only?
      NAMES=$(ALL_NAMES) # update NAMES variable with a new query? better?
    fi
    
    # if winner team name not in the DB yet, insert it now
    if [[ $( echo "$NAMES" | grep -c "$WINNER" ) -eq 0 ]]
    then
      INSERT_NAMES=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # NAMES=$(printf "$NAMES\n$WINNER")
      NAMES=$(ALL_NAMES)
    fi
    
    # if opponent team name not in the DB yet, insert it now
    if [[ $( echo "$NAMES" | grep -c "$OPPONENT" ) -eq 0 ]]
    then
      INSERT_NAMES=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # NAMES=$(printf "$NAMES\n$OPPONENT")
      NAMES=$(ALL_NAMES)
    fi
  
  fi
done

#### insert game match data
cat $INFILE | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # query for winner_id and opponent_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
  # insert games information
  if [[ $WINNER != "winner" ]]
  then
    INSERT_GAME_DATA=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
  fi

  # print which teams were added
  if [[ $INSERT_GAME_DATA == "INSERT 0 1" ]]
  then
    echo "Inserted game data for $WINNER vs $OPPONENT"
  fi
done
