#!/bin/bash

# Define the API endpoint and session token
endpoint=$1
session_token=$2

# Define the market filter for NBA Moneyline markets
market_filter=$3

# Define the output file for data collection
output_file="nba_data.txt"

# Make the API request to retrieve market information
response=$(curl -X POST -H "X-Application: APP_KEY_HERE" -H "X-Authentication: $session_token" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"SportsAPING/v1.0/listMarketCatalogue","params":'$market_filter',"id":1}' $endpoint)

# Check if the API request was successful
status=$(echo $response | jq -r '.status')
if [ "$status" != "SUCCESS" ]; then
  echo "Failed to retrieve market data. Status: $status"
  exit 1
fi

# Extract the market IDs from the response
market_ids=$(echo $response | jq -r '.result[].marketId')

# Loop through the market IDs and retrieve market book information
for market_id in $market_ids; do
  book_response=$(curl -X POST -H "X-Application: APP_KEY_HERE" -H "X-Authentication: $session_token" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"SportsAPING/v1.0/listMarketBook","params":{"marketIds":["'$market_id'"],"priceProjection":{"priceData":["EX_BEST_OFFERS"]}},"id":1}' $endpoint)
  
  # Check if the API request was successful
  book_status=$(echo $book_response | jq -r '.status')
  if [ "$book_status" != "SUCCESS" ]; then
    echo "Failed to retrieve market book data. Status: $book_status"
    exit 1
  fi
  
  # Extract the relevant data from the response and append to the output file
  home_team=$(echo $book_response | jq -r '.result[].runners[].runnerName' | head -n 1)
  away_team=$(echo $book_response | jq -r '.result[].runners[].runnerName' | tail -n 1)
  home_odds=$(echo $book_response | jq -r '.result[].runners[].ex.availableToBack[].price' | head -n 1)
  away_odds=$(echo $book_response | jq -r '.result[].runners[].ex.availableToBack[].price' | tail -n 1)
  echo "$home_team,$home_odds,$away_team,$away_odds" >> $output_file
done
