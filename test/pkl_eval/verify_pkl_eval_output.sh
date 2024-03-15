#! /bin/bash
set -e

THIS_DIR=$(cd "$(dirname "$0")" && pwd -P)
expected_file_fpath="$THIS_DIR/expected/$1.txt"

for file in $(cat "$expected_file_fpath"); do
      if [[ ! -f "$file" ]]; then
          echo "$file" "was not generated."
          exit 1
      fi
done
