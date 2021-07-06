library(dplyr)
library(data.table)
library(optparse)

# Load arguments ----------------------------------------------------------
# Environment: R 3.6.1
parse <- OptionParser()

option_list <- list(
  make_option('--fam', type='character', help="plink-format .fam file", action='store')
)

args = commandArgs(trailingOnly=TRUE)
opt <- parse_args(OptionParser(option_list=option_list), args=args)

fam.file=opt$fam

# Make dummy phenotype file -----------------------------------------------

fam.local = fread(fam.file,header = F,stringsAsFactors = F) 

dummy.pheno = fam.local %>% 
  select(FID = V1, IID = V2) %>% 
  mutate(dummy_pheno = runif(nrow(.),0,1)) %>% 
  mutate(dummy_pheno = round(dummy_pheno))

write.table(dummy.pheno,file='data/dummy_pheno.txt',quote=F,col.names=T,row.names=F)
