#!/bin/bash

docker-compose -f docker-compose-cli.yaml down --volumes
docker rm -f $(docker ps -aq)
docker rmi -f $(docker images -q)
