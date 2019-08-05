#!/bin/bash

docker stop $(docker ps -a -q --filter="name=minion.1")
docker rm $(docker ps -a -q --filter="name=minion.1")
