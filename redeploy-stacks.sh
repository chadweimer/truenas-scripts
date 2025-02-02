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
  echo "Updated stack '$key'."
done < "$1"

docker image prune -f
