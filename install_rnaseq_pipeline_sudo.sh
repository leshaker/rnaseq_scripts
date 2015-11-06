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

# replace docker with current release from github if kernel > 3.1
kernel_ver=`uname -r | grep -o -e "^[0-9]\.[0-9]"`
if (( $(echo "$kernel_ver>3.1" | bc) )); then
    echo "kernel version > 3.1"
    sudo service docker stop
    sudo rm /usr/bin/docker
    wget https://get.docker.com/builds/Linux/x86_64/docker-latest 
    mv ./docker-latest ./docker
    chmod a+x docker
    sudo chown root:root docker
    sudo mv docker /usr/bin/
    sudo service docker start
fi

# assign user to docker group and reload groups
sudo usermod -aG docker $USER
orig_group=`id -g`
newgrp docker
newgrp $orig_group

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

# install kallisto
wget https://github.com/pachterlab/kallisto/releases/download/v0.42.4/kallisto_linux-v0.42.4.tar.gz
tar xzf kallisto_linux-v0.42.4.tar.gz
rm kallisto_linux-v0.42.4.tar.gz
sudo mv kallisto_linux-v0.42.4/kallisto /usr/local/bin/
rm -rf kallisto_linux-v0.42.4
sudo chown root:wheel /usr/local/bin/kallisto
sudo chmod a+rw /usr/local/bin/kallisto

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
