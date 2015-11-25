#!/bin/bash
#input: transcript_expression
#output: gene_expression

set -e

input=$1
if [ -z "$2" ]; then
	output="genes_output.txt"
else
	output=$2
fi

join -1 1 -2 1 -o 1.2,2.4,2.5 -t $'\t' <(cat transcript_gene_table.txt | (read -r; printf "%s\n" "$REPLY"; sort)) <(cat $input | (read -r; printf "%s\n" "$REPLY"; sort)) \
    | awk '(NR==1) {print $1,$2,$3} (NR >1) {n[$1];for(i=2;i<=NF;i++)a[$1,i]+=$i}END{for(x in n){printf "%s\t", x;for(y=2;y<=NF;y++)printf "%s%s", a[x,y],(y==NF?ORS:OFS)}}' OFS='\t' \
	| (read -r; printf "%s\n" "$REPLY"; sort) \
    > $output

exit 0
