library(dplyr)
library(data.table)
library(optparse)

# Load arguments ----------------------------------------------------------
# Environment: R 3.6.1
parse <- OptionParser()

option_list <- list(
  make_option('--checklist', type='character', help="file for checklist", action='store')
)

args = commandArgs(trailingOnly=TRUE)
opt <- parse_args(OptionParser(option_list=option_list), args=args)

ckls=opt$checklist %>% fread(.,header=F,stringsAsFactors=F) %>% .$V1


# Check if files present --------------------------------------------------

all_files.PRS_folder = list.files('PRS',full.names = T,recursive = T)

ckls.missing = ckls %>% .[!. %in% all_files.PRS_folder]

write.table(ckls.missing,file='data/missing_score',
            quote = F,sep = '\n',row.names = F,col.names = F,append = F)
