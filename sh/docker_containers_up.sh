#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly MY_NAME="${ROOT_DIR##*/}"

# - - - - - - - - - - - - - - - - - - - -

wait_till_up()
{
  local n=10
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q ^${1}$ ; then
      return
    else
      sleep 0.5
    fi
  done
  echo "${1} not up after 5 seconds"
  docker logs "${1}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - -

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_till_up "test-${MY_NAME}-server"
wait_till_up "test-${MY_NAME}-client"
wait_till_up "test-${MY_NAME}-starter"
wait_till_up "test-${MY_NAME}-prometheus"
wait_till_up "test-${MY_NAME}-grafana"

# - - - - - - - - - - - - - - - - - - - -

docker exec \
  --user root \
    "test-${MY_NAME}-server" \
      sh -c 'cd /groups && rm -rf * && chown -R saver:saver /groups'

docker exec \
  --user root \
    "test-${MY_NAME}-server" \
      sh -c 'cd /katas && rm -rf * && chown -R saver:saver /katas'
