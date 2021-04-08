Calculate PRS
================
X Shen
08 April, 2021

This page include PRSice set up and input preparation for calculating
PRS. If you are already familiar with PRSice 2.0 and have a local copy
of the package, please skip to file preparation.

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
find . -executable -exec chmod +x {}
```

-----

## Environment preparation

R library required:

  - dplyr

Open R, test if these packages are installed.

``` r
library(dplyr)
```

If R gives an error message, install the package using:

``` r
install.packages('dplyr')
```

-----

## File preparation

#### Plink-format genetic data

Find plink-format genetic data. At least three files should be included
with suffixes: .bim, .bed, .fam.

#### Phenotype file

Create a dummy file with the .bim file for genetic data. Use command
given below.

``` bash
Rscript util/create_dummypheno.R <.bim file location>
```

Here is an example using plink data in the *data* folder:

``` bash
Rscript util/create_dummypheno.R data/TOY_TARGET_DATA.bim
```

A file will be created in *data/dummy\_pheno.txt .*

-----

### Run PRSice

Run file to generate all PRS using:

``` bash
bash job.PRS_prsice2.sh <base name for plink-format files>
```

Here is an example using plink data in the *data* folder:

``` bash
bash job.PRS_prsice2.sh data/TOY_TARGET_DATA.bim
```

-----

### A checklist for output files

**Polygenic risk scores**

  - PRS/MDD\_orig.all\_scores

  - PRS/MDD\_sbayesr.all\_scores

  - PRS/BMI\_orig.all\_scores

  - PRS/BMI\_sbayesr.all\_scores

  - …

**SNP lists used for calculating PRS**

  - PRS/MDD\_orig.snps

  - PRS/MDD\_sbayesr.snps

  - PRS/BMI\_orig.snps

  - PRS/BMI\_sbayesr.snps

  - …

-----

### Upload PRS and supportive files

Upload the entire *PRS* folder to the medflix server. \<to be finished\>
