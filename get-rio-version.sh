#!/bin/bash

set -eu

awk -F\" '/version =/ { print $2; exit }' MODULE.bazel
