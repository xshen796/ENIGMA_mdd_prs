Set up a PRS project
================
X Shen
06 July, 2021

-----

## Summary

These need to be prepared:

  - Summary statistics

  - SNP list(s)

  - A file to indicate inputs (a file called ‘input.txt’ in the *data*
    folder)

Details can be found below. An input file should be stored in the *data*
folder. Other items are recommended to put in the *data* folder but it
is not mandatory.

-----

### Summary statistics

A summary statistic (base dataset) file should be a tab-deliminated,
plain text file. Column names are essential for PRSice2.0. Please use
the default column names in the [PRSice2.0
tutorial](https://www.prsice.info/step_by_step/#base-dataset).

For example (ref: <https://www.prsice.info/step_by_step/#base-dataset>):

| SNP       | CHR | BP     | A1 | A2 | OR     | SE     | P      |
| --------- | --- | ------ | -- | -- | ------ | ------ | ------ |
| rs3094315 | 1   | 752566 | A  | G  | 0.9912 | 0.0229 | 0.7009 |
| rs3131972 | 1   | 752721 | A  | G  | 1.007  | 0.0228 | 0.769  |
| rs3131971 | 1   | 752894 | T  | C  | 1.003  | 0.0232 | 0.8962 |

### SNP list(s)

SNP list is used for restricting which SNPs used for calculating PRS. It
should be a single column of SNPs **without** a column name.

Example:

> rs3094315
> 
> rs3131972
> 
> rs3131971

### An input list

A file called ‘input.txt’ in the *data* folder should contain a table of
inputs for each PRS.

The file should be a tab-deliminated, plain text file. It should have
three columns:

  - File locations for SNP list(s)

  - File location for summary statistics

  - Method used for calculating PRS: CT/sbayesr
    (CT=clumping+thresholding; sbayesr=SBayesR)
    
    If CT was given for the method column, clumping would be applied. If
    sbayesr was given, no clumping would be applied.

Example:

> data/SNP\_all\_hardlist data/summstats/mdd\_summstats.example CT
> 
> data/SNP\_all\_hardlist data/summstats/mdd\_summstats.example sbayesr

In this example, two PRSs will be generated. For example, the first one
will be generated using SNPs from the ‘data/SNP\_all\_hardlist’ file,
sumstats from the ‘data/summstats/mdd\_summstats.example’ file and
clumping+thresholding method. You could also find an example file
[here](https://github.com/xshen796/ENIGMA_mdd_prs/tree/main/data/example.input.txt).

This PRSs will be stored in the
‘data/SNP\_all\_hardlist\_mdd\_summstats.example\_CT.all\_score’ file.

-----

## Outputs

All outputs will be generated in the *PRS* folder.

Here’s a rough checklist:

  - A ‘log.txt’ file generated by the pipeline

  - GRM files

  - PRS files
