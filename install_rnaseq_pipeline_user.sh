#!/bin/bash

# create folder structure
mkdir ~/RNAseq_pipeline/results
mkdir ~/RNAseq_pipeline/logs
mkdir ~/RNAseq_pipeline/data
mkdir ~/RNAseq_pipeline/ref

# install grape-nf pipeline
cd ~/RNAseq_pipeline
nextflow clone guigolab/grape-nf

# modify cpu and memory settings in grape-nf configuration
memory_kb=$(cat /proc/meminfo | grep 'MemTotal' | grep -oEi '[0-9]+')
memory_gb=$((memory_kb/1000000-1))

cpus=$(nproc)
if [[ "$cpus">1 ]]; then
    cpus_half=$(($cpus/2))
else
    cpus_half=$cpus
fi

config_files=$(find grape-nf/config/ -type f)
sed -i "s/cpus = 4/cpus = ${cpus_half}/" $config_files
sed -i "s/cpus = 8/cpus = ${cpus}/" $config_files
sed -i "s/memory = '15G'/memory = '$(($memory_gb/2))G'/" $config_files
sed -i "s/memory = '31G'/memory = '$(($memory_gb/3*2))G'/" $config_files
sed -i "s/memory = '62G'/memory = '${memory_gb}G'/" $config_files

# copy files for test case
cp ~/RNAseq_pipeline/grape-nf/data/* ~/RNAseq_pipeline/data/
cp ~/RNAseq_pipeline/grape-nf/test-index* ~/RNAseq_pipeline/

# run test case
nextflow run grape-nf -profile starrsem --index test-index.txt --genome data/genome.fa --annotation data/annotation.gtf -resume
sleep 5

nextflow run grape-nf -profile starrsem --index test-index-wbam.txt --genome data/genome.fa --annotation data/annotation.gtf -resume
mv data/test2_m4_n10_toGenome.bam data/test2_m4_n10.bam  
sleep 5

clear
cat $(find ~/RNAseq_pipeline/work/ -type f | grep command.err)
sudo rm -rf ~/RNAseq_pipeline/work
rm ~/RNAseq_pipeline/pipeline*
rm ~/RNAseq_pipeline/.nextflow.*
rm ~/RNAseq_pipeline/test-index*
rm ~/RNAseq_pipeline/data/*

# download hg19 GR38 reference genome
cd ~/RNAseq_pipeline
wget ftp://ftp.ncbi.nlm.nih.gov/genbank/genomes/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
mv GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz ref/GRCh38_no_alt_analysis_set.201503031.fa.gz
gunzip ref/GRCh38_no_alt_analysis_set.201503031.fa.gz

wget ftp://ftp.ncbi.nlm.nih.gov/genbank/genomes/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai
mv GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai ref/GRCh38_no_alt_analysis_set.201503031.fa.fai

wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_22/gencode.v22.annotation.gtf.gz 
mv gencode.v22.annotation.gtf.gz ref/gencode.v22.annotation.201503031.gtf.gz 
gunzip ref/gencode.v22.annotation.201503031.gtf.gz

# print completed message
clear; echo -e '\n#######################\nUser part of installation completed!\n#######################\n'
