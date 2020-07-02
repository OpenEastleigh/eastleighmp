#!/bin/sh

set -ev

SINCE=$(date --date='yesterday' +%F)
UNTIL=$(date +%F)

twurl "/1.1/search/tweets.json?q=(from:pauljholmes)+since:${SINCE}+until:${UNTIL}&result_type=recent&tweet_mode=extended" | \
  jq -c '.statuses[].full_text' | \
  tac | \
  split -l 1 - tweet

if [ ${TRAVIS_EVENT_TYPE} = "cron" ]; then
  echo "${TRAVIS_EVENT_TYPE}: Tweet here!"
else
  echo "${TRAVIS_EVENT_TYPE}: Don't tweet!"
  find . -type f -name 'tweet*' -print0 | \
    sort -z | \
    xargs -0 -L 1 sh -c 'file="$1"; tweet=$(cat "$file" | jq -r . | sed "s/\B@\([a-zA-Z0-9_]\+\)/\1/g" | cut -c 1-280); echo "Tweet: $tweet"' _
fi

echo Done
