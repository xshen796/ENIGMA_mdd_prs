Prepare GWAS summstats
================
X Shen
29 March, 2021

## **Annotate CHR:BP format to RS format**

-----

### **Download annotation file**

Check [this requiry](https://www.biostars.org/p/171557/)  

**Option 1 - download from web GUI**

  - Go to [UCSC Table Browser](https://genome.ucsc.edu/cgi-bin/hgTables)
    and download a list of all available SNPs with chr, pos and rs
    number.

  - Select options for all variants
    
      - clade: Mammal
    
      - genome: Human
    
      - assembly: Same as your SNPs
    
      - group: Variation
    
      - track: All SNPs (latest)
    
      - table: All SNPs
    
      - region: Genome
    
      - output format: selected fields from primary and related tables
    
      - output file: All-SNPs.txt
    
      - file type returned: plain text

  - Download plain txt file for all variants from the web GUI

**Option 2 - download from ftp server *(recommended)***

  - Check the ucsc [ftp
    server](http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/)
    (Caution: double check Build)

  - Find the latest list (find it on the web GUI). e.g. snp151

  - Download data.
    
    For common variants
    *(recommended)*:
    
    ``` bash
    wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/snp151Common.txt.gz
    ```
    
    For all
    variants:
    
    ``` bash
    wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/snp151.txt.gz
    ```

-----

### **Change SNP ID**

The following R script can be used to reformat reference data
(downloaded as described above) and update SNP IDs in the target GWAS
summary statistics.

Required R packages (check if you have installed): dplyr, data.table,
readr and tidyverse

  - Reformat reference data

<!-- end list -->

``` r
library(dplyr)      # For data managing
library(data.table) # Help read big files
library(readr)      # Write tsv files quickly

reformat_ref <- function(file.loc,output.loc){
  ref.dat = fread(file.loc,header=F) %>%
    select(CHR=V2,BP=V3,RSID=V5) %>%
    mutate(CHR=gsub('chr','',CHR)) %>% 
    mutate(CHR=as.numeric(CHR))
  write_tsv(ref.dat,path=output.loc,append = F,col_names = T,quote_escape = F)
}

# Use the function: reformat_ref({location of ucsc reference data},{output location})
# Example:
reformat_ref('~/shen/snp151Common.txt,gz','~/shen/snp151Common_chr_bp_rsid.tsv')
```

  - Change SNP ID from *CHR:BP* to *RS* names

<!-- end list -->

``` r
library(tidyverse)

reformat_summstats <- function(summstats.loc,ref.loc,output.loc,SNPcol = 'SNP'){
  
  # Read summstats
  summstats = fread(summstats.loc,header=T) 
  summstats.SNP.chr_bp = summstats.loc[,SNPcol] %>%
    str_split(.,':',simplify = T) %>% 
    as.data.frame
  colnames(summstats.SNP.chr_bp)=c('CHR','BP')
  
  # Read reference data (eg snp151Common_chr_bp_rsid.tsv)
  ref.dat = fread(ref.loc,header=T)
  
  # Reformat
  output.dat = left_join(summstats,ref.dat,by=c('CHR','BP'))
    return(output.dat)
}

# Use the function: 
# reformat_summstats({Location of summstats},
#                    {Location of downloaded reference data},
#                    {Location for reformatted summstats},
#                    {SNPcol: column name for SNPs in the summstats file})
# Example:

reformat_summstats(summstats.loc = 'MDD_GWAS.txt',
                   ref.loc = '~/shen/snp151Common_chr_bp_rsid.tsv',
                   output.loc = 'MDD_GWAS_new.txt',SNPcol = 'SNP')
```
