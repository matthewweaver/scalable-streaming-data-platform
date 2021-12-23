#!/usr/bin/env bash
set -e
MACHINE_NAME="development"
docker-machine create --driver virtualbox --virtualbox-no-vtx-check --virtualbox-memory 8192 --virtualbox-cpu-count 4 --virtualbox-disk-size=10000 ${MACHINE_NAME}