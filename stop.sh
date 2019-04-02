#!/bin/bash

docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml down --volumes
# docker rm -f $(docker ps -aq)
# docker network prune
# docker rmi -f $(docker images -q)
