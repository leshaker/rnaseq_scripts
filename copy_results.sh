#!/bin/bash

for i in $(find work/ -type f | grep .exitcode); 
do
	if [[ $(cat $i) == 0 ]]
		then
		# find all successful runs and copy the results files to ./results
		results="$(find ${i%/*} -maxdepth 4 -type f | grep '.results$\|.pdf$')"
		for j in $results
		do
			# copy file to results folder
			cp $j ./results
			echo "successfully copied ${j##*/}"
		done
		# remove successful runs after copying the results but keep genome folders
		isgenome="$(cat `find ${i%/*} -maxdepth 4 -type f | grep '.command.sh'`| grep 'runMode genomeGenerate\|rsem-prepare-reference\|samtools faidx GRCh38')"
		if [[ -z "$isgenome" ]]; then
			rm -rf ${i%/*}
			echo "removed successful run ${i%/*}"
		fi
	elif [ -s $i ] && [ $(cat $i) != 0 ]
	  	then
		# remove failed runs
	  	rm -rf ${i%/*}
	  	echo "removed failed run ${i%/*}"
  	fi
done

# remove empty directories
find work -maxdepth 2 -empty -type d -delete
echo "removed empty directories"
