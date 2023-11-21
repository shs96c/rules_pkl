#!/bin/bash
set -eu

version=$(eval "$1" --version)

if [ -z "$version" ]; then
  exit 1
else
  exit 0
fi