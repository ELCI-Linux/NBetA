#! /bin/bash

# This is NBA.sh

# Define the API endpoint and session token
endpoint="https://api.betfair.com/exchange/betting/json-rpc/v1"
session_token="YOUR_SESSION_TOKEN_HERE"

# Define the market filter for NBA Moneyline markets
market_filter='{"eventTypeIds":["4"],"competitionIds":["10881"],"marketTypeCodes":["MATCH_ODDS"],"marketBettingTypes":["ODDS"],"inPlayOnly":false}'

# Define your betting budget and floor
budget=1000
floor=500

# Loop until the session is closed or the budget is below the floor
until [[ $session == *"closed"* ]] || [ $budget -le $floor ]; do

    # Collect data using the Betfair API
    source data_collect_NBA.sh $endpoint $session_token $market_filter
    
    # Calculate implied probabilities
    source implied_prob_NBA.sh
    
    # Estimate true probabilities
    source true_prob_NBA.sh
    
    # Identify value bets
    source identifier.sh $budget
   
   
   # FURTHER COMMANDS WILL BE ADDED HERE
    
done
