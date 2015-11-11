#!/bin/bash
# inputs: datasource id filename
set -e

if [ -z "$1" ] || ([ "$1" != "GEO" ] && [ "$1" != "CCLE" ]); then
	datasource="CCLE"
else
	datasource=$1
fi

# get id and filename from input args
id=$2
fname=$3

# remove file extension
fname=${fname%.*}

if [ "$datasource" == "GEO" ]; then
	echo "downloading data file ${fname}.fastq.gz"
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

elif [ "$datasource" == "CCLE" ]; then

	# download bam file if it doesn't exist
	if [ ! -f "data/CCLE_${fname}.bam" ]; then
		echo "downloading data file CCLE_${fname}.bam"
		gtdownload --max-children 1 -k 0 -c cghub_public.key -v -d ${id} > logs/gt_${fname}.log 2> logs/gt_${fname}.err
		mv ${id}/${fname}.bam data/CCLE_${fname}.bam
		rm -rf ${id}/
		rm ${id}.gto
	fi

	if [[ ! -f "data/CCLE_${fname}_1.fastq.gz" || ! -f "data/CCLE_${fname}_2.fastq.gz" ]]; then
		echo "converting CCLE_${fname}.bam to fastq.gz"
		./convert_bam_to_fastq.sh ${PWD}/data/CCLE_${fname}.bam
	fi

	# write files to CCLE_index.txt
	echo -e "CCLE_${fname}\t CCLE_${fname}\t data/CCLE_${fname}_1.fastq.gz\t fastq FqRd1" >> CCLE_index.txt
	echo -e "CCLE_${fname}\t CCLE_${fname}\t data/CCLE_${fname}_2.fastq.gz\t fastq FqRd2" >> CCLE_index.txt
	echo -e "" >> CCLE_index.txt

	echo "CCLE_${fname} successfully downloaded and converted!"
fi

exit 0