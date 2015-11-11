#!/bin/bash

# run sudo part of installation
curl -fsSL https://github.com/leshaker/rnaseq_scripts/raw/master/install_rnaseq_pipeline_sudo.sh | bash

# run user part of installation
curl -fsSL https://github.com/leshaker/rnaseq_scripts/raw/master/install_rnaseq_pipeline_user.sh | bash

# run pipeline test
./run_pipeline_test.sh

# print completed message
clear; echo -e '\n#######################\nInstallation completed!\n#######################\n'
