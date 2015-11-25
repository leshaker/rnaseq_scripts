#!/bin/bash
# inputs: 
# datasource [CCLE]/GEO/USER 

set -e

source_options="CCLE GEO USER"
if [ -z "$1" ] || [[ ! "$source_options" =~ "$1" ]]; then
    datasource="CCLE"
else
    datasource=$1
fi

echo -e "\n\n**********************************************"
echo -e " downloading data from $datasource"
echo -e "**********************************************\n\n"

# get number of cores
cpus=$(nproc)

# run download_data.sh for each line in GEO/CCLE_data.txt in parallel
echo -n > download_job.sh
while read line; do
    echo -e "./download_data.sh $datasource $line" >> download_job.sh
done < ${datasource}_data.txt
parallel -j $cpus < download_job.sh
rm download_job.sh

# generate ${datasource}_index.txt
echo -n > ${datasource}_index.txt
while read line; do
    id=$(echo "$line" | cut -d$'\t' -f1)
    fname=$(echo "$line" | cut -d$'\t' -f2)
    if [ "$datasource" == "CCLE" ]; then
        fname=CCLE_${fname%\.bam*}
    fi
    # paired end
    if [ -f "data/${fname}_1.fastq.gz" ] && [ -f "data/${fname}_2.fastq.gz" ]; then
        echo -e "${fname}\t ${fname}\t data/${fname}_1.fastq.gz\t fastq FqRd1" >> ${datasource}_index.txt
        echo -e "${fname}\t ${fname}\t data/${fname}_2.fastq.gz\t fastq FqRd2" >> ${datasource}_index.txt
    # single end        
    elif [ -f "data/${fname}_1.fastq.gz" ] && [ ! -f "data/${fname}_2.fastq.gz" ]; then
        echo -e "${fname}\t ${fname}\t data/${fname}.fastq.gz\t fastq FqRd" >> ${datasource}_index.txt
    fi
    echo -e "" >> ${datasource}_index.txt
done < ${datasource}_data.txt
exit 0
