while getopts "d:" opt
do
   case "$opt" in
      d ) parameterD="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

plink_file=$parameterD


# Download hg19 genome build
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/snp151Common.txt.gz
gunzip snp151Common.txt.gz
mv snp151Common.txt data/

# Keep chr bp and rsID
Rscript util/check_genome_build.R --bim $parameterD



