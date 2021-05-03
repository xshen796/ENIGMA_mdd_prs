Calculate PRS
================
X Shen
23 April, 2021

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
Rscript util/create_dummypheno.R <.bim file location>
```

Here is an example using plink data in the *data* folder:

``` bash
Rscript util/create_dummypheno.R data/TOY_TARGET_DATA.bim
```

A file will be created as *data/dummy\_pheno.txt .*

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

Once you finished the protocol, please upload the entire *PRS* folder into your site folder in MediaFlux, which is only accessible by you and the chairs and coordinator of ENIGMA MDD (please let us know if you need the credentials): \<to be finished\>
