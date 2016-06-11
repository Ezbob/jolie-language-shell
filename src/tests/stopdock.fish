#!/usr/bin/fish
docker stop (docker ps -a -q); and docker rm (docker ps -a -q)
