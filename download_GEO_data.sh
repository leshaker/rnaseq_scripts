#!/bin/bash

id=$(cut --delimiter=' ' -f 2 < index.txt)
fastq-dump --gzip --split-files -O data/ $id 
rm -rf ~/ncbi