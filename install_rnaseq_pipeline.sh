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

# assign user to docker group and reload groups
sudo usermod -aG docker $USER
newgrp docker

# run user part of installation
./install_rnaseq_pipeline_user.sh

# print completed message
clear; echo -e '\n#######################\nInstallation completed!\n#######################\n'
