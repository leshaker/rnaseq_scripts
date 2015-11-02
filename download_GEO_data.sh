#!/bin/bash
# inputs: id filename
set -e

# get id and filename from input args
id=$1
fname=$2

# remove file extension
fname=${fname%.*}

fastq-dump --gzip --split-files -O data/ $id
rm -rf ~/ncbi 

# rename files and write to GEO_index.txt
if [ -e "data/${id}_1.fastq.gz" ] && [ -e "data/${id}_2.fastq.gz" ]; then
	mv data/${id}_1.fastq.gz data/${fname}_1.fastq.gz
	mv data/${id}_2.fastq.gz data/${fname}_2.fastq.gz
	echo -e "${fname}\t ${fname}\t data/${fname}_1.fastq.gz\t fastq FqRd1" >> GEO_index.txt
	echo -e "${fname}\t ${fname}\t data/${fname}_2.fastq.gz\t fastq FqRd2" >> GEO_index.txt
elif [ -e "data/${id}_1.fastq.gz" ] && [ ! -e "data/${id}_2.fastq.gz" ]; then
	mv data/${id}_1.fastq.gz data/${fname}.fastq.gz
	echo -e "${fname}\t ${fname}\t data/${fname}.fastq.gz\t fastq FqRd" >> GEO_index.txt
fi
echo -e "" >> GEO_index.txt

echo "$fname successfully downloaded!"

exit 0
