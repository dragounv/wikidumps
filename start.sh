#!/usr/bin/env bash

docker compose rm --stop -f db
docker compose up -d --remove-orphans