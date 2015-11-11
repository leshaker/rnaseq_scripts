#!/bin/bash
# inputs: datasource pipeline
set -e

# get number of cores
cpus=$(nproc)

echo -n > index.txt

if [ -z "$1" ] || ([ "$1" != "GEO" ] && [ "$1" != "CCLE" ]); then
	datasource="CCLE"
else
	datasource=$1
fi
if [ -z "$2" ] || ([ "$2" != "kallisto" ] && [ "$2" != "grape" ]); then
	pipeline="grape"
else
	pipeline=$2
fi

if [ "$pipeline" == "grape" ]; then
	echo -e "\n\n*************************************************************************"
	echo -e " running grape-nf pipeline using STAR and RSEM"
	echo -e "*************************************************************************\n\n"

	sudo service docker restart
	# iterate over all fastq files in GEO/CCLE_index.txt and run pipeline
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
			echo $line >> index.txt
		fi
	done < ${datasource}_index.txt

elif [ "$pipeline" == "kallisto" ]; then
	echo -e "\n\n*************************************************************************"
	echo -e " running pseudoalignment and quantification using kallisto"
	echo -e "*************************************************************************\n\n"
	# generate genome index if necessary
	if [ ! -f "ref/GRCh38_rel79_cdna_all_index" ]; then
		echo "generating genome index"
		kallisto index -i ref/GRCh38_rel79_cdna_all_index ref/GRCh38.rel79.cdna.all.fa.gz
	fi

	# iterate over all fastq files in GEO/CCLE_index.txt and run pipeline
	while read line; do
		if [ -z "$line" ]; then
			nlines=$(cat index.txt | cut -d' ' -f1 | wc -l)
			samplename=$(cat index.txt | cut -d' ' -f1 | head -1)
			if [[ nlines -eq 2 ]]; then
				fastqfile1=$(cat index.txt | cut -d' ' -f3 | grep "_1.fastq")
				fastqfile2=$(cat index.txt | cut -d' ' -f3 | grep "_2.fastq")
				kallisto quant --plaintext --bias -t ${cpus} -i ref/GRCh38_rel79_cdna_all_index -o results/$samplename $fastqfile1 $fastqfile2
			else
				fastqfile=$(cat index.txt | cut -d' ' -f3 | grep ".fastq")
				kallisto quant --plaintext --single --bias -t ${cpus} -i ref/GRCh38_rel79_cdna_all_index -o results/$samplename $fastqfile
			fi
			echo ""
			echo "done!"
			echo ""
			echo -n > index.txt
		else
			echo $line >> index.txt
		fi
	done < ${datasource}_index.txt	

else
	echo "Please select a vaild pipeline!"
fi

exit 0
