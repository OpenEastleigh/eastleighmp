#!/bin/sh

set -ev

: ${FROM:?"FROM must be set to the Twitter account to mirror"}
SINCE=$(date --date='yesterday' +%F)
UNTIL=$(date +%F)

twurl "/1.1/search/tweets.json?q=(from:${FROM})+since:${SINCE}+until:${UNTIL}&result_type=recent&tweet_mode=extended" | \
  jq -c '.statuses[].full_text' | \
  tac | \
  split -l 1 - tweet

if [ -f tweetaa ]; then
  if [ ${TRAVIS_EVENT_TYPE} = "cron" ]; then
    echo "${TRAVIS_EVENT_TYPE}: Tweet here!"
    find . -type f -name 'tweet*' -print0 | \
      sort -z | \
      xargs -0 -L 1 sh -c 'file="$1"; tweet=$(cat "$file" | jq -r . | sed "s/\B@\([a-zA-Z0-9_]\+\)/\1/g" | cut -z -b 1-279 | sed "s/\S*$//"); echo "Tweeting: $tweet"; twurl -d "status=$tweet" /1.1/statuses/update.json' _
  else
    echo "${TRAVIS_EVENT_TYPE}: Don't tweet!"
    find . -type f -name 'tweet*' -print0 | \
      sort -z | \
      xargs -0 -L 1 sh -c 'file="$1"; tweet=$(cat "$file" | jq -r . | sed "s/\B@\([a-zA-Z0-9_]\+\)/\1/g" | cut -z -b 1-279 | sed "s/\S*$//"); echo "Not tweeting: $tweet"' _
  fi
else
  echo "${TRAVIS_EVENT_TYPE}: No tweets!"
fi

echo Done
