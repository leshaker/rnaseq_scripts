#!/bin/bash

cd ~/RNAseq_pipeline

# copy files for test case
cp grape-nf/data/* data/
cp grape-nf/test-index* ./

# run test cases
nextflow run grape-nf -profile starrsem --index test-index.txt --genome data/genome.fa --annotation data/annotation.gtf -resume
sleep 5

nextflow run grape-nf -profile starrsem --index test-index-wbam.txt --genome data/genome.fa --annotation data/annotation.gtf -resume
mv data/test2_m4_n10_toGenome.bam data/test2_m4_n10.bam  
sleep 5

./copy_results.sh
ls -lt --color=auto results/

sleep 5

# print warning
clear; echo -e "\n*****************************************************\nWarning: This pipeline test will remove all files in \nthe folers 'work', data' and 'results'. \nIf you want to keep these files press 'Ctrl + C' now\n*****************************************************\n"; sleep 20

# remove files
rm -rf work
rm pipeline*
rm .nextflow.*
rm test-index*
rm data/test*
rm data/*.md5
rm data/annotation.gtf
rm data/genome.fa
rm results/sample1*
