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

For installing only the sudo (packages, docker, tools in /opt/) or the user part (pipeline, reference genome etc.), type
```bash
curl -fsSL https://github.com/leshaker/rnaseq_scripts/raw/master/install_rnaseq_pipeline_sudo.sh | bash
```
or 
```bash
curl -fsSL https://github.com/leshaker/rnaseq_scripts/raw/master/install_rnaseq_pipeline_user.sh | bash
```
respectively.


## Processing data from GEO
Add data sets to the file `GEO_data.txt` in the following format
```txt
SRR2537160 GSM1898288_polycysticstemcell_expansionmedium_1_17p6
```
where the first part represenst the *SRA run identifier* from [SRA](http://www.ncbi.nlm.nih.gov/sra) and the second is the filename (ideally containing the GEO or SRA identifier).

Then run the script `run_loop.sh` for downloading, converting and processing all files in the `GEO_data.txt` file.
```
cd ~/RNAseq_pipeline
./run_loop.sh GEO grape
```
Consider running the command within a `screen` as the processing will take about 4h per file (on 36 core, 60GB RAM machine).

## Processing data from CCLE
Add data sets to the file `CCLE_data.txt` in the following format
```txt
b39b60cd-ed66-4824-9548-6e1396da753c	G20463.C2BBe1.2.bam
e6b5d8f8-76ac-4598-954a-aadbf4306afa	G27383.CL-40.1.bam
```
where the first part represenst the *Analysis Id* and the second is the *Filename* from the [CGHub Browser](https://browser.cghub.ucsc.edu/search/?platform=%28ILLUMINA%29&state=%28live%29&library_strategy=%28RNA-Seq%29&study=%28*Other_Sequencing_Multiisolate%29) 

Then run the script `run_loop.sh` for downloading, converting and processing all files in the `CCLE_data.txt` file.
```
cd ~/RNAseq_pipeline
./run_loop.sh CCLE grape
```
Consider running the command within a `screen` as the processing will take about 4h per file (on 36 core, 60GB RAM machine).

## Processing user supplied data
Add data sets to the file `USER_data.txt` in the following format
```txt
NK0_rep1	Sample1_NK_cells_untreated
NK0_rep2	Sample2_NK_cells_untreated
NK0_rep3	Sample3_NK_cells_untreated
NK5_rep1	Sample1_NK_cells_treated_with_5mg
NK5_rep2	Sample2_NK_cells_treated_with_5mg
NK5_rep3	Sample3_NK_cells_treated_with_5mg
```
where the first part represents the input filename (withouth `fastq.gz` extension) and the second is the output filename.

Then run the script `run_loop.sh` for processing all files in the `USER_data.txt` file.
```
cd ~/RNAseq_pipeline
./run_loop.sh USER kallisto
```
Consider running the command within a `screen` as the processing will take about 2h per file (on 36 core, 60GB RAM machine).
