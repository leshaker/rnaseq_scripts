#!/bin/bash
# inputs: 
# datasource [CCLE]/GEO/USER 
# pipeline [grape]/kallisto 
# delete_data [false]/true

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

if [ -z "$3" ]; then
	delete_data=false
else
	delete_data=$3
fi

# get number of cores
cpus=$(nproc)

# split ${datasource}_data.txt into subsets of size $cpus and iterate over them
cp -rf ${datasource}_data.txt ${datasource}_tmp.txt
split -l $cpus -d ${datasource}_tmp.txt ${datasource}_tmp
file_list=$(find . -maxdepth 1 -type f -name "${datasource}_tmp*" | sort)
for file in $file_list; do
	mv -f $file ${datasource}_data.txt
	echo -n > "${datasource}_index.txt"
	./download_loop.sh $datasource && ./pipeline_loop.sh $datasource $pipeline $delete_data
done
mv -f ${datasource}_tmp.txt ${datasource}_data.txt

# shutdown if running on amazon instance
if [ ! "$(hostname)" == "rnaseq2" ] && [ -n "$(uname -a | grep -o -e "amzn")" ]; then
	sudo shutdown -h now
fi
