#!/bin/bash
set -e
sudo service docker restart

# iterate over all fastq files in CCLE_index.txt and run pipeline
while read line; do
	if [ -z "$line" ]; then
		nextflow run grape-nf -profile starrsem --index index.txt --genome ref/GRCh38_no_alt_analysis_set.201503031.fa --annotation ref/gencode.v22.annotation.201503031.gtf -resume 2>&1 > pipeline.log
		echo ""
		echo "done!"
		echo ""
		echo -n > index.txt
		./copy_results.sh
		echo ""
	else		
		echo $line
		echo $line >> index.txt
	fi
done < CCLE_index.txt

exit 0
