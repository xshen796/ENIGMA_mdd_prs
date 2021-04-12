Calculate PRS
================
X Shen
09 April, 2021

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

#### Phenotype file

Create a dummy file with the .bim file. Use command given below.

``` bash
Rscript util/create_dummypheno.R --bim <.bim file location>
```

Here is an example using plink data in the *data* folder:

``` bash
Rscript util/create_dummypheno.R --bim data/TOY_TARGET_DATA.bim
```

A file will be created as *data/dummy\_pheno.txt .*

-----

### Run PRSice

Run the job file to generate all PRS using the command below.

``` bash
bash job.PRS_prsice2.sh <base name for plink-format files>
```

Here is an example using plink data in the *data* folder:

``` bash
bash job.PRS_prsice2.sh data/TOY_TARGET_DATA
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
