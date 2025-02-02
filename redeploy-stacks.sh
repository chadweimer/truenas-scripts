#!/bin/bash

# Usage: redeploy-stacks.sh <hooks-file>
#
# Example: redeploy-stacks.sh ~/.portainer-hooks.conf
#
# Hooks file format:
#
# stack1=https://hook.url
# stack2=https://hook.url
#

while IFS='=' read -r key value; do
  # Skip lines starting with sharp
  # or lines containing only space or empty lines
  [[ "$key" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue

  echo "Updating stack '$key'..."
  curl -sSX POST $value

  # Don't try to update all the stacks at once.
  # We're not trying to guarantee each one is complete; just rate limit.
  echo "Sleeping for 1 minute..."
  sleep 1m

  echo "Updated stack '$key'."
done < "$1"

docker image prune -f
