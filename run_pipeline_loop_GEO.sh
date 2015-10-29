#!/bin/bash

# kill all related processes
sudo pkill nextflow
sudo pkill java
sudo pkill rsem
sudo pkill STAR
sudo service docker restart

clear
echo -n > index.txt

# iterate over all fastq files in GEO_index.txt and run pipeline
set -e
while read line; do
	if [ -z "$line" ]; then
		echo "downloading data from GEO"
		#./download_GEO_data.sh
		echo "done!"
		nextflow run grape-nf -profile starrsem --index index.txt --genome ref/GRCh38_no_alt_analysis_set.201503031.fa --annotation ref/gencode.v22.annotation.201503031.gtf -resume 2>&1 > pipeline.log
		echo ""
		tail -3 pipeline.log
		echo ""
		echo "done!"
		echo ""
		# rm data/*.fastq.gz
		echo -n > index.txt
		./copy_results.sh
		echo ""
	else		
		echo $line
		echo $line >> index.txt
	fi
done < GEO_index.txt

#sudo shutdown -h now
