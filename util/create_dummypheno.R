library(data.table)
library(dplyr)

# Load arguments ----------------------------------------------------------
# Environment: R 3.6.1
parse <- OptionParser()

option_list <- list(
  make_option('--bim', type='character', help="plink-format .bim file", action='store')
)

args = commandArgs(trailingOnly=TRUE)
opt <- parse_args(OptionParser(option_list=option_list), args=args)

bim.file=opt$bim

# Make dummy phenotype file -----------------------------------------------

bim.local = read.delim(bim.file,header = F,quote = F,row.names = F,col.names = F,stringsAsFactors = F) 

dummy.pheno = bim.local %>% 
  select(FID = V1, IID = V2) %>% 
  mutate(dummy_pheno = runif(nrow(.),0,1)) %>% 
  mutate(dummy_pheno = round(dummy_pheno))

write.table(dummy.pheno,file='data/dummy_pheno.txt')