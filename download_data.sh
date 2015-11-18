#!/bin/bash
# inputs: 
# datasource [CCLE]/GEO/USER 
# id 
# filename

set -e

source_options="CCLE GEO USER"
if [ -z "$1" ] || [[ ! "$source_options" =~ "$1" ]]; then
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

	# download fastq file if it doesn't exist
	if [ ! -f "data/${fname}_1.fastq.gz" ] || [ ! -f "data/${fname}_2.fastq.gz" ]; then
		echo "downloading data file ${fname}.fastq.gz"
		fastq-dump --gzip --split-files -O data/ $id
		rm -rf ~/ncbi 
	fi

	# rename files and write to GEO_index.txt
	# paired end
	if [ -f "data/${id}_1.fastq.gz" ] && [ -f "data/${id}_2.fastq.gz" ]; then
		mv data/${id}_1.fastq.gz data/${fname}_1.fastq.gz
		mv data/${id}_2.fastq.gz data/${fname}_2.fastq.gz
		echo -e "${fname}\t ${fname}\t data/${fname}_1.fastq.gz\t fastq FqRd1" >> GEO_index.txt
		echo -e "${fname}\t ${fname}\t data/${fname}_2.fastq.gz\t fastq FqRd2" >> GEO_index.txt
	# single end		
	elif [ -f "data/${id}_1.fastq.gz" ] && [ ! -f "data/${id}_2.fastq.gz" ]; then
		mv data/${id}_1.fastq.gz data/${fname}.fastq.gz
		echo -e "${fname}\t ${fname}\t data/${fname}.fastq.gz\t fastq FqRd" >> GEO_index.txt
	fi
	echo -e "" >> GEO_index.txt
	
	echo "$fname successfully downloaded!"

elif [ "$datasource" == "CCLE" ]; then

	# download bam file if bam or fastq doesn't exist
	if [ ! -f "data/CCLE_${fname}.bam" ] && ([ ! -f "data/CCLE_${fname}_1.fastq.gz" ] || [ ! -f "data/CCLE_${fname}_2.fastq.gz" ]); then
		echo "downloading data file CCLE_${fname}.bam"
		gtdownload --max-children 1 -k 300 -c cghub_public.key -v -d ${id} > logs/gt_${fname}.log 2> logs/gt_${fname}.err
		mv ${id}/${fname}.bam data/CCLE_${fname}.bam
		rm -rf ${id}/
		rm ${id}.gto
	fi

	# convert bam to fastq
	if [ ! -f "data/CCLE_${fname}_1.fastq.gz" ] || [ ! -f "data/CCLE_${fname}_2.fastq.gz" ]; then
		echo "converting CCLE_${fname}.bam to fastq.gz"
		./convert_bam_to_fastq.sh ${PWD}/data/CCLE_${fname}.bam
	fi

	# write files to CCLE_index.txt
	echo -e "CCLE_${fname}\t CCLE_${fname}\t data/CCLE_${fname}_1.fastq.gz\t fastq FqRd1" >> CCLE_index.txt
	echo -e "CCLE_${fname}\t CCLE_${fname}\t data/CCLE_${fname}_2.fastq.gz\t fastq FqRd2" >> CCLE_index.txt
	echo -e "" >> CCLE_index.txt

	echo "CCLE_${fname} successfully downloaded and converted!"

elif [ "$datasource" == "USER" ]; then

	echo -e "looking for user supplied file data/${id}_1/_2.fastq.gz"
	# rename files and write to USER_index.txt
	# paired end
	if [ -f "data/${id}_1.fastq.gz" ] && [ -f "data/${id}_2.fastq.gz" ]; then
		mv data/${id}_1.fastq.gz data/${fname}_1.fastq.gz
		mv data/${id}_2.fastq.gz data/${fname}_2.fastq.gz
		echo -e "${fname}\t ${fname}\t data/${fname}_1.fastq.gz\t fastq FqRd1" >> USER_index.txt
		echo -e "${fname}\t ${fname}\t data/${fname}_2.fastq.gz\t fastq FqRd2" >> USER_index.txt
	# single end		
	elif [ -f "data/${id}_1.fastq.gz" ] && [ ! -f "data/${id}_2.fastq.gz" ]; then
		mv data/${id}_1.fastq.gz data/${fname}.fastq.gz
		echo -e "${fname}\t ${fname}\t data/${fname}.fastq.gz\t fastq FqRd" >> USER_index.txt
	fi
	echo -e "" >> USER_index.txt
fi

exit 0
