#!/bin/bash

set -eu

sed -n 's/.*"org.pkl-lang:pkl-cli-java:\([^"]*\)".*/\1/p' < MODULE.bazel | head -1
