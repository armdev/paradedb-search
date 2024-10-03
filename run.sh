#!/usr/bin/env bash

set -e

docker compose --compatibility up -d --build
docker ps -a
docker logs --follow paradedb
