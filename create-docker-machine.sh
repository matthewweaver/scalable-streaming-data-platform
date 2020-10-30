#!/usr/bin/env bash
set -e
MACHINE_NAME="development"
docker-machine create --driver virtualbox ${MACHINE_NAME}