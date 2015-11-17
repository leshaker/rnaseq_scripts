#!/bin/bash
# inputs: datasource pipeline
set -e

source_options="CCLE GEO USER"
if [ -z "$1" ] || [[ ! "$source_options" =~ "$1" ]]; then
	datasource="CCLE"
else
	datasource=$1
fi

pipeline_options="grape kallisto"
if [ -z "$2" ] || [[ ! "$pipeline_options" =~ "$2" ]]; then
	pipeline="grape"
else
	pipeline=$2
fi

echo -n > "${datasource}_index.txt"
./download_loop.sh $datasource && ./pipeline_loop.sh $datasource $pipeline

# shutdown if running on amazon instance
if [ ! "$(hostname)" == "rnaseq2" ] && [ -n "$(uname -a | grep -o -e "amzn")" ]; then
	sudo shutdown -h now
fi
