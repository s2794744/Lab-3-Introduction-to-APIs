#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

LOG_FILE="logs/lab3.log"

log() {
    echo "$1" >> "$LOG_FILE"
}

cleanup() {
    log "LAB3_END"
}

trap cleanup EXIT

log "BASH_OK"

# Step 3 - Get a dad joke from the API
HTTP_STATUS=$(curl -s -o data/dad_joke.json \
    -w "%{http_code}" \
    -H "Accept: application/json" \
    https://icanhazdadjoke.com/)

if [[ "$HTTP_STATUS" -ne 200 ]]; then
    log "CURL_JOKE_FAIL"
    exit 1
fi

log "CURL_JOKE_OK"

# Step 3 - Extract the joke using jq
jq -r '.id, .joke' data/dad_joke.json > data/dad_joke.txt

log "JQ_JOKE_OK"

# Step 4 - Create a deck of cards

DECK_STATUS=$(curl -s -o data/deck_create.json \
    -w "%{http_code}" \
    "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1")

if [ "$DECK_STATUS" != "200" ]; then
    log "DECK_CREATE_FAIL"
    exit 1
fi

log "DECK_CREATE_OK"

deck_id=$(jq -r '.deck_id' data/deck_create.json)

# Step 4 - Draw two cards from the deck
DRAW_STATUS=$(curl -s -o data/deck_draw.json \
    -w "%{http_code}" \
    "https://deckofcardsapi.com/api/deck/$deck_id/draw/?count=2")

if [ "$DRAW_STATUS" != "200" ]; then
    log "DECK_DRAW_FAIL"
    exit 1
fi

log "DECK_DRAW_OK"

# Step 4 - Extract card information using jq
jq -r '.cards[] | "\(.value) of \(.suit)"' data/deck_draw.json > data/deck_summary.txt

jq -r '"Remaining cards: \(.remaining)"' data/deck_draw.json >> data/deck_summary.txt

log "JQ_DECK_OK"
