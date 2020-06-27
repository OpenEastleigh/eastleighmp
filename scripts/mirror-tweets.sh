#!/bin/sh

set -ev

SINCE=$(date --date='yesterday' +%F)
UNTIL=$(date +%F)

twurl -j "/1.1/search/tweets.json?q=(from:pauljholmes)+since:${SINCE}+until:${UNTIL}&result_type=recent&tweet_mode=extended" | jq --raw-output '.statuses[].full_text' | sed 's/\B@\([a-zA-Z0-9_]\+\)/\1/g' | cut -c 1-280 > tweets.txt

cat tweets.txt
