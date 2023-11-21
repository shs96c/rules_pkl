#!/bin/bash
set -eu

value=$(eval "$PKL_BIN" --version)

if [ -z "$value" ]; then
  exit 1
else
  exit 0
fi