cat << EOF > "${HOME}/.twurlrc"
---
profiles:
  ${TWITTER_USERNAME}:
    ${TWITTER_CONSUMER_KEY}:
      username: ${TWITTER_USERNAME}
      consumer_key: ${TWITTER_CONSUMER_KEY}
      consumer_secret: ${TWITTER_CONSUMER_SECRET}
      token: ${TWITTER_TOKEN}
      secret: ${TWITTER_SECRET}
configuration:
  default_profile:
  - ${TWITTER_USERNAME}
  - ${TWITTER_CONSUMER_KEY}
EOF
