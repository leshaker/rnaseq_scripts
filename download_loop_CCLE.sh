#!/bin/bash
set -e

# get number of cores
cpus=$(nproc)

# download all bam files in first_batch.txt
echo -n > CCLE_index.txt

echo -n > download_job.sh
while read line; do
	echo -e "./download_CCLE_data.sh $line" >> download_job.sh
done < first_batch.txt

parallel -j $cpus < download_job.sh

exit 0