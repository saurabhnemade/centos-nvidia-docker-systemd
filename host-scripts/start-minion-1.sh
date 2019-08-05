#!/bin/bash

docker stop $(docker ps -a -q --filter="name=minion.1")
docker rm $(docker ps -a -q --filter="name=minion.1")
docker run --name minion.1 -d -p 2020:22 --privileged --gpus all -v /sys/fs/cgroup:/sys/fs/cgroup:ro saurabh/docker-nvidia-systemd:latest
docker exec -it minion.1 systemctl restart systemd-user-sessions.service
