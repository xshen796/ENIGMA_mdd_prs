while getopts "g:p:o:s:n:" opt
do
   case "$opt" in
      g ) parameterG="$OPTARG" ;;
      p ) parameterP="$OPTARG" ;;
      o ) parameterO="$OPTARG" ;;
      s ) parameterS="$OPTARG" ;;
      n ) parameterN="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done




# This script needs to run with R

# Settings ------------------------------------------------------------------------------

prsice_R_file='/exports/igmm/eddie/GenScotDepression/shen/Tools/PRSice/PRSice.R'
prsice_binary_file='/exports/igmm/eddie/GenScotDepression/shen/Tools/PRSice/PRSice_linux'

# space/tab deliminated summary statistics in plain text
gwas_summstats=$parameterS 

# prefix of the bed,fam,bim files
plink_files=$parameterG 

# Phenotype for MDD diagnosis: space/tab deliminated file. Columns: FID, IID, phenotype (e.g. MDD_diagnosis)
phenotype_file=$parameterP
pheno_name=$parameterN

# prefix for the output files
output_prefix=$parameterO 



# PRSice script:

$prsice_R_file \
    --prsice $(which PRSice_linux) \
    --base $gwas_summstats \
    --target $plink_files \
    --thread 3 \
    --stat BETA \
    --binary-target T \
    --pheno $phenotype_file \
    --pheno-col $pheno_name \
    --no-clump \
    --bar-levels 1 \
    --fastscore \
    --all-score \
    --out $output_prefix