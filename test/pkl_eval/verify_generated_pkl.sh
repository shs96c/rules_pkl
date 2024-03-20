#! /bin/bash
set -e

THIS_DIR=$(cd "$(dirname "$0")" && pwd -P)
expected_file_fpath="$THIS_DIR/$1"

actual_file_fpath="$THIS_DIR/$2"

EXPECTED_CONTENTS=$(cat $expected_file_fpath)
ACTUAL_CONTENTS=$(cat $actual_file_fpath)

if [[ $EXPECTED_CONTENTS != $ACTUAL_CONTENTS ]]; then
  echo "Expected: $EXPECTED_CONTENTS but got: $ACTUAL_CONTENTS"
  exit 1
fi