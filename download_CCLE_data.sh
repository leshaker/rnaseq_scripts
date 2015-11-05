#!/bin/bash
# inputs: id filename
set -e

# get id and filename from input args
id=$1
fname=$2

# remove file extension
fname=${fname%.*}

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

echo "conversion of $fname done!"

# write files to CCLE_index.txt
echo -e "CCLE_${fname}\t CCLE_${fname}\t data/CCLE_${fname}_1.fastq.gz\t fastq FqRd1" >> CCLE_index.txt
echo -e "CCLE_${fname}\t CCLE_${fname}\t data/CCLE_${fname}_2.fastq.gz\t fastq FqRd2" >> CCLE_index.txt
echo -e "" >> CCLE_index.txt

exit 0