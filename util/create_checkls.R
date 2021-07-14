library(dplyr)
library(data.table)
library(optparse)

# Load arguments ----------------------------------------------------------
# Environment: R 3.6.1
parse <- OptionParser()

option_list <- list(
  make_option('--plink', type='character', help="plink-format files", action='store')
)

args = commandArgs(trailingOnly=TRUE)
opt <- parse_args(OptionParser(option_list=option_list), args=args)

file.prefix=opt$plink %>% basename

# load input list

inputs = fread('data/input.txt',header=F,stringsAsFactors=F) %>% 
  select(summstats=V2,snpls=V1,method=V3) %>% 
  apply(.,MARGIN = 2,basename) %>% 
  as.data.frame(stringsAsFactors=F)

# create check list -------------------------------------------------------

# log file
chk.ls = 'log.txt'

# grm
chk.ls = chk.ls %>% c(.,paste0(file.prefix,
                               c('.grm.id','.grm.bin','.log','.grm.N.bin')))

ls.score.basename = inputs %>% apply(.,1,paste0,collapse="_")

# score files
chk.ls = ls.score.basename %>% paste0(.,'.all_score') %>% c(chk.ls,.)

# snp lists
chk.ls = ls.score.basename %>% paste0(.,'.snp') %>% c(chk.ls,.)

# log files
chk.ls = ls.score.basename %>% paste0(.,'.log') %>% c(chk.ls,.)


# Write check list --------------------------------------------------------

chk.ls = paste0('PRS/',chk.ls)

write.table(chk.ls,file='PRS/local_checklist',
            append = F,sep = '\n',row.names = F,col.names = F,quote = F)

