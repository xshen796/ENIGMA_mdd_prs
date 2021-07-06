library(dplyr)
library(data.table)
library(optparse)

# Load arguments ----------------------------------------------------------
# Environment: R 3.6.1
parse <- OptionParser()

option_list <- list(
  make_option('--bim', type='character', help="plink-format .bim file", action='store')
)

args = commandArgs(trailingOnly=TRUE)
opt <- parse_args(OptionParser(option_list=option_list), args=args)

bim.file=paste0(opt$bim,'.bim')
base.name=opt$bim %>% basename

# Load data ----------------------------------------------------------------
snp151common = fread('data/snp151Common.txt',stringsAsFactors=F,header=F) %>%
    select(CHR.ref=V2,BP.ref=V4,RSID=V5) %>%
    mutate(CHR.ref=gsub('chr','',CHR.ref)) %>% 
    filter(CHR.ref!='X',CHR.ref!='Y') %>%
    filter(nchar(CHR.ref)<3) %>% 
    mutate(CHR.ref=as.numeric(CHR.ref))

local.bim = fread(bim.file,stringsAsFactors=F,header=F) %>%
    select(CHR=V1,BP=V4,RSID=V2)

# Process   ---------------------------------------------------------------

# count matching N
n.rsID = length(grep('^rs',local.bim$RSID))
n.rsID_present = sum(local.bim$RSID %in% snp151common$RSID)
dat.chrbp_match = merge(local.bim,snp151common,by='RSID') %>%
   filter(CHR==CHR.ref) %>%
   filter(BP==BP.ref)
n.chrbp_match = nrow(dat.chrbp_match)

output.table = data.frame(percentage = c(n.rsID_present/n.rsID,n.chrbp_match/n.rsID_present),
			  type = c('present','loc_matched'))

# save file 
if ((n.rsID_present/n.rsID>0.85)&(n.chrbp_match/n.rsID_present>0.9)){
    cat ('Local genetic data is under genome build hg19/GRCh37.\n')
}else{
    cat ('Local genetic data is using an imcompatible genome build.\n')
}

write.table(output.table,file=paste0('data/check_genome_build_',base.name,'.txt'),
            col.names=F,row.names=F,sep='\t',quote=F)
  


