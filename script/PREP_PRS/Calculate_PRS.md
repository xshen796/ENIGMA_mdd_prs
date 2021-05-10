Calculate PRS
================
X Shen
10 May, 2021

For more information about PRSice 2.0, see its [wiki
page](http://prsice.info/)

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
  - optparse

Open R, test if these packages are installed.

``` r
library(dplyr)
library(optparse)
```

If R gives an error message, install the package(s) using:

``` r
install.packages('dplyr')
install.packages('optparse')
```

-----

## File preparation

#### Plink-format genetic data

At least three files should be included with suffixes: .bim, .bed, .fam.
Please make sure genetic data is under genome build hg19/GRCh37.

If you are not sure, the PRS pipeline will check automatically.

#### Phenotype file

Create a dummy file with the .bim file. Use command given below.

``` bash
Rscript util/create_dummypheno.R <.bim file location>
```

Here is an example using plink data in the *data* folder:

``` bash
Rscript util/create_dummypheno.R data/TOY_TARGET_DATA.bim
```

A file will be created as *data/dummy\_pheno.txt .*

#### 1000genome plink files

If your sample has less than 1000 participants, it is better to use the
1000genome data as LD reference.

You can download the plink files from
[here](https://datasync.ed.ac.uk/index.php/s/MR4ZkvBbUcswO8d). Password:
enigma. Stored the files in the *data* folder.

\!\!\! The PRS script will detect if your sample is too small (N\<1000).

-----

### Run PRSice

Run the job file to generate all PRS using the command below.

``` bash
bash job.PRS_prsice2.sh -d <base name for plink-format files>
```

Here is an example using plink data in the *data* folder:

``` bash
bash job.PRS_prsice2.sh -d data/TOY_TARGET_DATA
```

**\!\!** If you see an error about duplicated variants looking like
below, run the above command again. The script will pick up the valid
SNP list when re-calculating PRS.

> Error: A total of 7456 duplicated SNP ID detected out of 5958288 input
> SNPs\! …

-----

### A checklist for output files

Check if all files present in the *PRS* folder. A checklist can be found
[here](https://github.com/xshen796/ENIGMA_mdd_prs/blob/main/script/PREP_PRS/CheckList_output.md).

-----

### Upload PRS and supportive files

Upload the entire *PRS* folder to the medflix server. See a step-by-step
guide
[here](https://github.com/xshen796/ENIGMA_mdd_prs/blob/main/docs/Accessing%20your%20folder%20on%20MediaFlux%20ENIGMA%20MDD%20storage%20system%20updated%20Aug2020%5B2%5D.pdf).
