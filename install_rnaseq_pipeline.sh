#!/bin/bash

# add epel repository
sudo yum install -y epel-release
sudo yum repolist

# update packages
sudo yum update -y

# install htop,nano, wget, screen, git, pigz
sudo yum install -y \
	htop \
	nano \
	wget \
	screen \
	pigz \
	git

# install gcc, make, zlib, bzip, ncurses, java
sudo yum install -y \
	gcc \
	make \
	zlib-devel \
	bzip2 \
	ncurses-devel \
	ncurses \
	java

# install docker
curl -sSL https://get.docker.com/ | sh

# replace docker with current release from github
sudo service docker stop
sudo rm /usr/bin/docker
wget https://get.docker.com/builds/Linux/x86_64/docker-1.8.3 && mv ./docker-1.8.3 ./docker
chmod a+x docker && sudo chown root:root docker
sudo mv docker /usr/bin/
sudo service docker start

# assign user to docker group and reload groups
sudo usermod -aG docker $USER
newgrp docker

# install nextflow
curl -fsSL get.nextflow.io | bash

sudo mv nextflow /usr/local/bin/

sudo /usr/local/bin/nextflow -self-update
sudo chown root /usr/local/bin/nextflow
sudo chgrp root /usr/local/bin/nextflow
sudo chmod a+xr /usr/local/bin/nextflow

# create folder structure
mkdir RNAseq_pipeline
mkdir RNAseq_pipeline/results
mkdir RNAseq_pipeline/logs
mkdir bin

# add $HOME/bin to path if necessary
usr_path=$(echo $PATH | grep -oEi "$HOME/bin")
if [ -z "$usr_path" ]; then
	PATH="$HOME/bin:$PATH"
	echo 'export PATH=$HOME/bin:$PATH' >>~/.bash_profile
    echo "Added $HOME/bin to PATH"
    sleep 5
fi

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

# install sra tools
wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.5.4-1/sratoolkit.2.5.4-1-centos_linux64.tar.gz
tar xzf sratoolkit.2.5.4-1-centos_linux64.tar.gz
rm sratoolkit.2.5.4-1-centos_linux64.tar.gz
mv sratoolkit.2.5.4-1-centos_linux64 ~/sratoolkit
ln -s ~/sratoolkit/bin/* ~/bin

# install bam2fastq
cd ~
git clone --recursive https://github.com/leshaker/bam2fastq.git
cd ~/bam2fastq
chmod a+x bam2fastq.py
ln -s ~/bam2fastq/bam2fastq.py ~/bin/bam2fastq
cd ~/RNAseq_pipeline

# install genetorrent
wget https://cghub.ucsc.edu/software/downloads/GeneTorrent/3.8.7/GeneTorrent-download-3.8.7-207-CentOS6.4.x86_64.tar.gz
tar xzf GeneTorrent-download-3.8.7-207-CentOS6.4.x86_64.tar.gz
rm GeneTorrent-download-3.8.7-207-CentOS6.4.x86_64.tar.gz
mv cghub ~/
wget https://cghub.ucsc.edu/software/downloads/cghub_public.key 
mv cghub_public.key ~/RNAseq_pipeline

# install samtools
wget https://github.com/samtools/samtools/releases/download/1.2/samtools-1.2.tar.bz2
tar xvf samtools-1.2.tar.bz2
rm samtools-1.2.tar.bz2
mv samtools-1.2 ~/samtools
cd ~/samtools
make
ln -s ~/samtools/samtools ~/bin/

# install bedtools
wget https://github.com/arq5x/bedtools2/releases/download/v2.25.0/bedtools-2.25.0.tar.gz
tar xzf bedtools-2.25.0.tar.gz
rm bedtools-2.25.0.tar.gz
mv bedtools2 ~/
cd ~/bedtools2
make
ln -s ~/bedtools2/bin/bedtools ~/bin/
cd ~/RNAseq_pipeline

# install GNU parallel
cd ~
wget http://ftpmirror.gnu.org/parallel/parallel-20150922.tar.bz2
bzip2 -dc parallel-20150922.tar.bz2 | tar xvf -
rm parallel-20150922.tar.bz2
mv parallel-20150922 parallel && cd parallel
./configure --prefix=$HOME && make && make install
cd ~/RNAseq_pipeline

# pull docker images
sudo service docker start
docker pull grape/contig:rgcrg-0.1
docker pull grape/mapping:star-2.4.0j
docker pull grape/quantification:rsem-1.2.21
docker pull grape/inferexp:rseqc-2.3.9

# copy files for test case
mkdir data
mkdir ref
cp grape-nf/data/* ./data/
cp grape-nf/test-index* ./

# run test case
nextflow run grape-nf -profile starrsem --index test-index.txt --genome data/genome.fa --annotation data/annotation.gtf -resume
sleep 5

nextflow run grape-nf -profile starrsem --index test-index-wbam.txt --genome data/genome.fa --annotation data/annotation.gtf -resume
mv data/test2_m4_n10_toGenome.bam data/test2_m4_n10.bam  
sleep 5

clear
cat $(find work/ -type f | grep command.err)
sudo rm -rf work

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

# install custom pipeline scripts
cd ~/RNAseq_pipeline
git clone --recursive https://github.com/leshaker/rnaseq_scripts.git
chmod a+x rnaseq_scripts/*.sh
mv rnaseq_scripts/*.sh ./
rm -rf rnaseq_scripts/

# print completed message
clear; echo -e '\n#######################\nInstallation completed!\n#######################\n'
