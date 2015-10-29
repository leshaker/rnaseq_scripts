#!/bin/bash
set -e

./download_loop_CCLE.sh && ./pipeline_loop_CCLE.sh

#sudo shutdown -h now