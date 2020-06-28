#!/bin/sh

set -ev

SINCE=$(date --date='yesterday' +%F)
UNTIL=$(date +%F)

twurl -j "/1.1/search/tweets.json?q=(from:pauljholmes)+since:${SINCE}+until:${UNTIL}&result_type=recent&tweet_mode=extended" | \
  jq --raw-output '.statuses[].full_text' | \
  sed 's/\B@\([a-zA-Z0-9_]\+\)/\1/g' | \
  cut -c 1-280 | \
  tac > tweets.txt

MAX_TWEET_LEN=$(wc -L < tweets.txt)

if [ ${MAX_TWEET_LEN:-0} -gt 0 ]; then
  cat tweets.txt
fi

if [ ${TRAVIS_EVENT_TYPE} = "cron" ] && [ ${MAX_TWEET_LEN:-0} -gt 0 ]; then
  echo Tweet here
  # xargs -I{} twurl -d 'status={}' /1.1/statuses/update.json < tweets.txt
else
  echo ${TRAVIS_EVENT_TYPE}
fi
