#!/usr/bin/env bash
set -e
MACHINE_NAME="development"
docker-machine create --driver virtualbox --virtualbox-memory 4096 --virtualbox-cpu-count 4 ${MACHINE_NAME}