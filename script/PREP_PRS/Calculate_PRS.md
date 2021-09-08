Calculate PRS
================
X Shen
08 September, 2021

This pipeline calculates PRS for the ENIGMA MDD PRS projects. There are
a total of 6 steps in the protocol. Please use a linux machine for the
pipeline.

For more information about PRSice 2.0, see its [wiki
page](http://prsice.info/). For GCTA, see [wiki
page](https://cnsgenomics.com/software/gcta).

-----

## Set up a local copy of the github repository

Clone files:

``` bash
git clone https://github.com/xshen796/ENIGMA_mdd_prs.git
cd ENIGMA_mdd_prs
```

Set permission to files:

``` bash
find . -executable -exec chmod +x {} \;
```

-----

## Environment preparation

R libraries required:

  - dplyr
  - data.table
  - optparse

Open R, test if these packages are installed.

``` r
library(dplyr)
library(optparse)
library(data.table)
```

If R gives an error message, install the package(s) using:

``` r
install.packages('dplyr')
install.packages('optparse')
install.packages('data.table')
```

-----

## File preparation

#### Plink-format genetic data

At least three files should be included with suffixes: .bim, .bed, .fam.
Please make sure genetic data is under genome build hg19/GRCh37.

If you are not sure, simply run the PRS pipeline and it will check
automatically.

#### GWAS sumstats

Please download all GWAS sumstats using the following commands.
**Password:
enigma**

``` bash
curl -u "MxG9YdrVLc29St7" "https://datasync.ed.ac.uk/public.php/webdav" -o data/sumstats.tar.gz
tar -xvf data/sumstats.tar.gz -C data/
```

#### Phenotype file

Create a dummy file with the .fam file. Use command given below.

``` bash
Rscript util/create_dummypheno.R --fam <.bim file location>
```

Here is an example using plink data in the *data* folder:

``` bash
Rscript util/create_dummypheno.R --fam data/1000G_eur_chr22.fam
```

A file will be created as *data/dummy\_pheno.txt .*

#### 1000genome plink files

If your sample has less than 1000 participants, use the following steps
to download the 1000genome data to use as LD reference.

You can download the plink files and store in the *data* folder. Use the
command below. You’ll be asked to give a password for each file.
**Password:
enigma**.

``` bash
curl -u "ZtQCeM3yoDdPg6H" "https://datasync.ed.ac.uk/public.php/webdav" -o data/1000G.tar.gz
tar -xvf data/1000G.tar.gz -C data/
```

\!\!\! The PRS script will detect if your sample is too small (N\<1000).

-----

### Run PRSice

Run the job file to generate all PRS using the command below.

``` bash
bash job.PRS_prsice2.sh -d <base name for plink-format files>
```

Here is an example using plink data in the *data* folder:

``` bash
bash job.PRS_prsice2.sh -d data/1000G_eur_chr22
```

-----

### A checklist for output files

The pipeline checks if all files present in the *PRS* folder. A
checklist for all files necessary for downstream analysis can be found
in file *PRS/local\_checklist*. Missing files are listed in
*PRS/missing\_score*.

If all CT method PRS are missing (for example, …CT.all\_score, …CT.snp),
it is likely that you haven’t downloaded the 1000G CEU plink files in
the data folder. Please check the ‘1000genome plink files’ section in
this protocol.

-----

### Upload PRS and supportive files

Upload the entire *PRS* folder to the medflix server. See a step-by-step
guide
[here](https://github.com/xshen796/ENIGMA_mdd_prs/blob/main/docs/Accessing%20your%20folder%20on%20MediaFlux%20ENIGMA%20MDD%20storage%20system%20updated%20Aug2020%5B2%5D.pdf).
