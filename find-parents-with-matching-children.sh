#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  find_parents_with_matching_children.sh <PARENT_DIR> <CHILD_GLOB_PATTERN> [MIN_COUNT]

Examples:
  # Find any folder under /repo that has 2+ immediate subfolders matching "*somestring*"
  find_parents_with_matching_children.sh /repo '*somestring*'

  # Same, but require at least 3 matching subfolders
  find_parents_with_matching_children.sh /repo '*somestring*' 3

Notes:
  - CHILD_GLOB_PATTERN is a shell glob (like "*foo*"), applied to *immediate* subfolder names.
  - The search considers every directory under PARENT_DIR (including PARENT_DIR itself).
EOF
}

parent_dir="${1:-}"
pattern="${2:-}"
min_count="${3:-2}"

if [[ -z "${parent_dir}" || -z "${pattern}" ]]; then
  usage >&2
  exit 2
fi

if [[ ! -d "${parent_dir}" ]]; then
  echo "ERROR: Not a directory: ${parent_dir}" >&2
  exit 2
fi

# Ensure MIN_COUNT is a positive integer
if ! [[ "${min_count}" =~ ^[0-9]+$ ]] || [[ "${min_count}" -lt 1 ]]; then
  echo "ERROR: MIN_COUNT must be a positive integer (got: ${min_count})" >&2
  exit 2
fi

# For each directory under parent_dir, count immediate child directories matching pattern
# Print directories whose count >= min_count
find -P "${parent_dir}" -type d -print0 |
  while IFS= read -r -d '' dir; do
    # Count matching immediate subdirectories
    # -mindepth/-maxdepth are per-dir to keep it "within that folder"
    count="$(
      find -P "${dir}" -mindepth 1 -maxdepth 1 -type d -name "${pattern}" -print 2>/dev/null | wc -l | tr -d '[:space:]'
    )"

    if [[ "${count}" -ge "${min_count}" ]]; then
      printf '%s\t%s\n' "${count}" "${dir}"
    fi
  done
