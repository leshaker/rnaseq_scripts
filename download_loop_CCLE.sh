#!/bin/bash
set -e

# get number of cores
cpus=$(nproc)

# download all bam files in CCLE_data.txt
echo -n > CCLE_index.txt

echo -n > download_job.sh
while read line; do
	echo -e "./download_CCLE_data.sh $line" >> download_job.sh
done < CCLE_data.txt

parallel -j $cpus < download_job.sh

exit 0
