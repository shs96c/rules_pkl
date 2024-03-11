#! /bin/bash

set -e

GOT_CONTENTS=$(cat example.yaml)
EXPECTED_CONTENTS=$(cat expected_output.yaml)

if [[ $GOT_CONTENTS != $EXPECTED_CONTENTS ]]; then
    echo "example.yaml does not contain expected contents."
    exit 1
fi


