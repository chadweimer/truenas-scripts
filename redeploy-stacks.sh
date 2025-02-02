#!/bin/bash

# Usage: redeploy-stacks.sh <hooks-file>
#
# Example: redeploy-stacks.sh ~/.portainer-hooks.conf
#
# Hooks file format:
#
# stack1=https://hook.url
# stack2=https://hook.url

declare -a hooks
while IFS='=' read -r key value; do
  # Skip lines starting with sharp
  # or lines containing only space or empty lines
  [[ "$key" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue

  # Intentionally not using associative array to preserve order
  hooks+=("stackname='$key';hookurl='$value'")
done < "$1"

for hook in "${hooks[@]}"
do
  eval $hook
  echo "Updating stack '$stackname'..."
  curl -sSX POST $hookurl

  # Don't try to update all the stacks at once.
  # We're not trying to guarantee each one is complete; just rate limit.
  echo "Sleeping for 1 minute..."
  sleep 1m

  echo "Updated stack '$stackname'."
done

docker image prune -f
