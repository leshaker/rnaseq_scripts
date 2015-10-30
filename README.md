# rnaseq_scripts
Custom scripts and tools for running the guigolab/grape-nf pipeline on Amazon EC2 (Amazon Linux AMI) or other CentOS/RedHat machines

## Requirements
- System running CentOS 6.7/7 or Amazon Linux AMI
- at least 8 cores
- at least 32GB RAM
- approximately 50GB of free disk space per raw data file

## Installation
Run the following command in a shell on the machine where you want to process your data
```bash
curl -fsSL https://github.com/leshaker/rnaseq_scripts/raw/master/install_rnaseq_pipeline.sh | bash
```
The script will install all dependencies and tools needed for processing files from GEO, CCLE or other sources (`.bam`, `.sra` or `.fastq` files).

## Processing data from CCLE
Add data sets to the file `CCLE_data.txt` in the following format
```txt
e2280d6e-7ed4-4749-a9e2-f7bd0a810c0c	G27222.769-P.1.bam
166efd97-7b71-4089-be92-d8d006f86c3b	G20495.786-O.2.bam
```
where the first part represenst the *Analysis Id* and the second is the *Filename* from the [CGHub Browser](https://browser.cghub.ucsc.edu/search/?platform=%28ILLUMINA%29&state=%28live%29&library_strategy=%28RNA-Seq%29&study=%28*Other_Sequencing_Multiisolate%29) 

Then run the script `run_loop_CCLE.sh` for downloading, converting and processing all files in the `CCLE_data.txt` file.
```
cd ~/RNAseq_pipeline
./run_loop_CCLE.sh
```
Consider running the command within a `screen` as the processing will take about 4h per file (on 36 core, 60GB RAM machine).
