#!/bin/bash
containerId=$1

if [[ -n containerId ]]; then
	sudo docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $containerId
else
	echo "Expected 1 argument: container id"
fi