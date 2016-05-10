#!/bin/bash

port=$1
fileName=$2
if [[ -n $3 ]]; then detach=$3;	else detach=false; fi

pathToFile=$(dirname $(readlink -f $fileName))

maxMem="256m"
cpuShares="512"


reg='^[0-9]+$'
if [[ -e $2 && $1 =~ $reg ]]; then
	if [[ "$detach" = true ]]; then
		sudo docker run -t -d --read-only --volume=$pathToFile:/home/jolie:ro -m=$maxMem --cpu-shares=$cpuShares --expose=$port ezbob/jolie:0.1.1 $fileName 
	else
		sudo docker run -t --rm --read-only --volume=$pathToFile:/home/jolie:ro -m=$maxMem --cpu-shares=$cpuShares --expose=$port ezbob/jolie:0.1.1 $fileName 
	fi
else 
    echo "Expected arguments: port_to_expose file_name detach_bool "
fi
