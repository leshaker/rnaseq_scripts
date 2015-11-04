#!/bin/bash

# install custom pipeline scripts
mkdir ~/RNAseq_pipeline
cd ~/RNAseq_pipeline
git clone --recursive https://github.com/leshaker/rnaseq_scripts.git
chmod a+x ~/RNAseq_pipeline/rnaseq_scripts/*.sh
mv ~/RNAseq_pipeline/rnaseq_scripts/*.sh ~/RNAseq_pipeline
rm -rf rnaseq_scripts/

# run sudo part of installation
./install_rnaseq_pipeline_sudo.sh

# replace docker with current release from github
sudo service docker stop
sudo rm /usr/bin/docker
wget https://get.docker.com/builds/Linux/x86_64/docker-latest 
mv ./docker-latest ./docker
chmod a+x docker
sudo chown root:root docker
sudo mv docker /usr/bin/
sudo service docker start

# assign user to docker group and reload groups
sudo usermod -aG docker $USER
newgrp docker

# run user part of installation
./install_rnaseq_pipeline_user.sh

# print completed message
clear; echo -e '\n#######################\nInstallation completed!\n#######################\n'
