#!/bin/bash

# install custom pipeline scripts
mkdir ~/RNAseq_pipeline
cd ~/RNAseq_pipeline
git clone --recursive https://github.com/leshaker/rnaseq_scripts.git
rm rnaseq_scripts/install_rnaseq_pipeline*
chmod a+x rnaseq_scripts/*.sh
mv rnaseq_scripts/*.sh ~/RNAseq_pipeline
rm -rf rnaseq_scripts/

# install CGHub key file
wget https://cghub.ucsc.edu/software/downloads/cghub_public.key 
mv cghub_public.key ~/RNAseq_pipeline

# create folder structure
mkdir ~/RNAseq_pipeline/results
mkdir ~/RNAseq_pipeline/logs
mkdir ~/RNAseq_pipeline/data
mkdir ~/RNAseq_pipeline/ref

# install grape-nf pipeline
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

# download hg19 GR38 reference genome
wget ftp://ftp.ncbi.nlm.nih.gov/genbank/genomes/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
mv GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz ref/GRCh38_no_alt_analysis_set.201503031.fa.gz
gunzip ref/GRCh38_no_alt_analysis_set.201503031.fa.gz

wget ftp://ftp.ncbi.nlm.nih.gov/genbank/genomes/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh38/seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai
mv GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.fai ref/GRCh38_no_alt_analysis_set.201503031.fa.fai

wget ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_22/gencode.v22.annotation.gtf.gz 
mv gencode.v22.annotation.gtf.gz ref/gencode.v22.annotation.201503031.gtf.gz 
gunzip ref/gencode.v22.annotation.201503031.gtf.gz

wget http://bio.math.berkeley.edu/kallisto/transcriptomes/Homo_sapiens.GRCh38.rel79.cdna.all.fa.gz
mv Homo_sapiens.GRCh38.rel79.cdna.all.fa.gz ref/GRCh38.rel79.cdna.all.fa.gz

# print completed message
clear; echo -e '\n#######################\nUser part of installation completed!\n#######################\n'
