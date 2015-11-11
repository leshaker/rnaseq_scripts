#!/bin/bash
# inputs: datasource pipeline
set -e

if [ -z "$1" ] || ([ "$1" != "GEO" ] && [ "$1" != "CCLE" ]); then
	datasource="CCLE"
else
	datasource=$1
fi
if [ -z "$2" ] || ([ "$2" != "kallisto" ] && [ "$2" != "grape" ]); then
	pipeline="grape"
else
	pipeline=$2
fi

echo -n > "${datasource}_index.txt"
./download_loop.sh $datasource && ./pipeline_loop.sh $datasource $pipeline

# sudo shutdown -h now
