#!/bin/bash
set -e

# get number of cores
cpus=$(nproc)

# download all fastq files in GEO_data.txt
echo -n > GEO_index.txt

echo -n > download_job.sh
while read line; do
	echo -e "./download_GEO_data.sh $line" >> download_job.sh
done < GEO_data.txt

parallel -j $cpus < download_job.sh

exit 0
