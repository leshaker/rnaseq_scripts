#!/bin/bash
set -e

currentDir=$PWD
input=$1
data=${input%/*}
file=${input%.bam}
prefix=${file##*/}
prefix_tmp=${prefix}_tmp 

cd $data
if [ -d "$prefix_tmp" ]; then
	rm -rf $prefix_tmp
fi
mkdir $prefix_tmp
bam2fastq ${file}.bam ./$prefix_tmp > ../logs/bam2fq_${prefix}.log 2> ../logs/bam2fq_${prefix}.err
rm ${file}.bam

cd $prefix_tmp

fastq1=${data}/${prefix}_1.fastq.gz
if [ ! -f "$fastq1" ]; then
	cat $(find *.1.fq) | gzip > ${prefix}_1.fastq.gz 
	mv -f ${prefix}_1.fastq.gz ../
fi

fastq2=${data}/${prefix}_2.fastq.gz
if [ ! -f "$fastq2" ]; then
	cat $(find *.2.fq) | gzip > ${prefix}_2.fastq.gz
	mv -f ${prefix}_2.fastq.gz ../ 
fi

cd ..
rm -rf $prefix_tmp

cd $currentDir

exit 0