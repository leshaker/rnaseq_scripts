#!/bin/bash
# inputs: datasource
set -e

if [ -z "$1" ] || ([ "$1" != "GEO" ] && [ "$1" != "CCLE" ]); then
	datasource="CCLE"
else
	datasource=$1
fi

echo -e "\n\n**********************************************"
echo -e " downloading data from $datasource"
echo -e "**********************************************\n\n"

# get number of cores
cpus=$(nproc)

# download all fastq/bam files in GEO/CCLE_data.txt
echo -n > ${datasource}_index.txt

echo -n > download_job.sh

while read line; do
	echo -e "./download_data.sh $datasource $line" >> download_job.sh
done < ${datasource}_data.txt

parallel -j $cpus < download_job.sh

exit 0
