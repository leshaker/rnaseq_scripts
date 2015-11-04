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
sudo service docker start

# assign user to docker group and reload groups
sudo usermod -aG docker $USER
newgrp docker

# install nextflow
curl -fsSL get.nextflow.io | bash

sudo mv nextflow /usr/local/bin/
sudo chown root /usr/local/bin/nextflow
sudo chgrp root /usr/local/bin/nextflow
sudo chmod a+xr /usr/local/bin/nextflow

# install sra tools
wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.5.4-1/sratoolkit.2.5.4-1-centos_linux64.tar.gz
tar xzf sratoolkit.2.5.4-1-centos_linux64.tar.gz
rm sratoolkit.2.5.4-1-centos_linux64.tar.gz
sudo mv sratoolkit.2.5.4-1-centos_linux64 /opt/sratoolkit
sudo ln -s /opt/sratoolkit/bin/* /usr/local/bin

# install bam2fastq
git clone --recursive https://github.com/jhart99/bam2fastq.git
sudo mv bam2fastq /opt/
sudo chmod a+x /opt/bam2fastq/bam2fastq.py
sudo ln -s /opt/bam2fastq/bam2fastq.py /usr/local/bin/bam2fastq

# install genetorrent
wget https://cghub.ucsc.edu/software/downloads/GeneTorrent/3.8.7/GeneTorrent-download-3.8.7-207-CentOS6.4.x86_64.tar.gz
tar xzf GeneTorrent-download-3.8.7-207-CentOS6.4.x86_64.tar.gz
rm GeneTorrent-download-3.8.7-207-CentOS6.4.x86_64.tar.gz
sudo mv cghub /opt/
sudo chmod a+x /opt/cghub/bin/*
sudo ln -s /opt/cghub/bin/* /usr/local/bin/
sudo ln -s /opt/cghub/libexec/* /usr/local/libexec/
sudo ln -s /opt/cghub/lib/* /usr/local/lib/
sudo ln -s /opt/cghub/share/GeneTorrent /usr/local/share/

wget https://cghub.ucsc.edu/software/downloads/cghub_public.key 
mv cghub_public.key ~/RNAseq_pipeline

# install samtools
wget https://github.com/samtools/samtools/releases/download/1.2/samtools-1.2.tar.bz2
tar xvf samtools-1.2.tar.bz2
rm samtools-1.2.tar.bz2
sudo mv samtools-1.2 /opt/samtools
cd /opt/samtools
sudo make
sudo ln -s /opt/samtools/samtools /usr/local/bin/
cd ~

# install bedtools
wget https://github.com/arq5x/bedtools2/releases/download/v2.25.0/bedtools-2.25.0.tar.gz
tar xzf bedtools-2.25.0.tar.gz
rm bedtools-2.25.0.tar.gz
sudo mv bedtools2 /opt/
cd /opt/bedtools2
sudo make
sudo ln -s /opt/bedtools2/bin/bedtools /usr/local/bin/
cd ~

# install GNU parallel
wget http://ftpmirror.gnu.org/parallel/parallel-20150922.tar.bz2
bzip2 -dc parallel-20150922.tar.bz2 | tar xvf -
rm parallel-20150922.tar.bz2
mv parallel-20150922 parallel 
cd parallel
./configure && make && sudo make install
cd ~
rm -rf parallel

# fix permissions
sudo chown -R root /opt/
sudo chgrp -R root /opt/
sudo chmod -R a+r /opt/

# pull docker images
docker pull grape/contig:rgcrg-0.1
docker pull grape/mapping:star-2.4.0j
docker pull grape/quantification:rsem-1.2.21
docker pull grape/inferexp:rseqc-2.3.9

# print completed message
clear; echo -e '\n#######################\nsudo part of installation completed!\n#######################\n'
