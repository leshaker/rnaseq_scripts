#!/bin/bash
# inputs: 
# datasource [CCLE]/GEO/USER 
# pipeline [grape]/kallisto 
# delete_data [false]/true

set -e

source_options="CCLE GEO USER"
if [ -z "$1" ] || [[ ! "$source_options" =~ "$1" ]]; then
	datasource="CCLE"
else
	datasource=$1
fi

pipeline_options="grape kallisto"
if [ -z "$2" ] || [[ ! "$pipeline_options" =~ "$2" ]]; then
	pipeline="grape"
else
	pipeline=$2
fi

if [ -z "$3" ]; then
	delete_data=false
else
	delete_data=$3
fi

# get number of cores
cpus=$(nproc)

echo -n > index.txt

if [ "$pipeline" == "grape" ]; then
	echo -e "\n\n*************************************************************************"
	echo -e " running grape-nf pipeline using STAR and RSEM"
	echo -e "*************************************************************************\n\n"

	sudo service docker restart
	# iterate over all fastq files in GEO/CCLE/USER_index.txt and run pipeline
	while read line; do
		if [ -z "$line" ]; then
			nextflow run grape-nf -profile starrsem --index index.txt --genome ref/GRCh38_no_alt_analysis_set.201503031.fa --annotation ref/gencode.v22.annotation.201503031.gtf -resume 2>&1 > pipeline.log
			echo -e "\ndone!\n"
			./copy_results.sh
			# delete data
			if $delete_data; then
				files=$(cut -d' ' -f3 index.txt)
				rm $files
			fi
			echo -e "\n"
			echo -n > index.txt
		else		
			echo $line >> index.txt
		fi
	done < ${datasource}_index.txt

elif [ "$pipeline" == "kallisto" ]; then
	echo -e "\n\n*************************************************************************"
	echo -e " running pseudoalignment and quantification using kallisto"
	echo -e "*************************************************************************\n\n"
	# generate genome index if necessary
	if [ ! -f "ref/GRCh38_rel79_cdna_all_kallisto_index" ]; then
		echo "generating genome index"
		kallisto index -i ref/GRCh38_rel79_cdna_all_kallisto_index ref/GRCh38.rel79.cdna.all.fa
	fi

	# iterate over all fastq files in GEO/CCLE/USER_index.txt and run pipeline
	while read line; do
		if [ -z "$line" ]; then
			nlines=$(cat index.txt | cut -d' ' -f1 | wc -l)
			samplename=$(cat index.txt | cut -d' ' -f1 | head -1)
			if [[ nlines -eq 2 ]]; then
				fastqfile1=$(cat index.txt | cut -d' ' -f3 | grep "_1.fastq")
				fastqfile2=$(cat index.txt | cut -d' ' -f3 | grep "_2.fastq")
				kallisto quant --bias -t ${cpus} -b ${cpus} -i ref/GRCh38_rel79_cdna_all_kallisto_index -o results/$samplename $fastqfile1 $fastqfile2
			else
				fastqfile=$(cat index.txt | cut -d' ' -f3 | grep ".fastq") 
				kallisto quant --single --bias -t ${cpus} -b ${cpus} -i ref/GRCh38_rel79_cdna_all_kallisto_index -o results/$samplename $fastqfile
			fi
			# rename results files and remove folder
			mv -f results/${samplename}/abundance.tsv results/${samplename}.kallisto.abundance
			mv -f results/${samplename}/abundance.h5 results/${samplename}.kallisto.bootstrap.h5
			mv -f results/${samplename}/run_info.json results/${samplename}.kallisto.run_info.json
			rm -rf results/${samplename}
			# delete data
			if $delete_data; then
				files=$(cut -d' ' -f3 index.txt)
				rm $files
			fi
			echo -e "\ndone!\n"
			echo -n > index.txt
		else
			echo $line >> index.txt
		fi
	done < ${datasource}_index.txt	
fi

exit 0
