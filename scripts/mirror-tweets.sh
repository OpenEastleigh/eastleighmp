#!/bin/sh

set -ev

: ${FROM:?"FROM must be set to the Twitter account to mirror"}
SINCE=$(date --date='yesterday' +%F)
UNTIL=$(date +%F)

twurl "/1.1/search/tweets.json?q=(from:${FROM})+since:${SINCE}+until:${UNTIL}&result_type=recent&tweet_mode=extended" | \
  jq -c '.statuses[].full_text | gsub("\\B@(?<user>[a-zA-Z0-9_]+)"; .user) | if (.[280:281] | test ("\\S")) then .[:280] | sub("\\S*$";"") else .[:280] end' | \
  tac | \
  split -l 1 - tweet

if [ -f tweetaa ]; then
  if [ ${TRAVIS_EVENT_TYPE} = "cron" ]; then
    echo "${TRAVIS_EVENT_TYPE}: Tweet here!"
    find . -type f -name 'tweet*' -print0 | \
      sort -z | \
      xargs -0 -L 1 sh -c 'file="$1"; tweet=$(he --decode < "$file" | jq -r @uri); echo "Tweeting: $tweet"; twurl --raw-data "status=$tweet" /1.1/statuses/update.json' _
  else
    echo "${TRAVIS_EVENT_TYPE}: Don't tweet!"
    find . -type f -name 'tweet*' -print0 | \
      sort -z | \
      xargs -0 -L 1 sh -c 'file="$1"; tweet=$(he --decode < "$file" | jq -r @uri); echo "Not tweeting: $tweet"' _
  fi
else
  echo "${TRAVIS_EVENT_TYPE}: No tweets!"
fi

echo Done
