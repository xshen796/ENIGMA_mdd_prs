while getopts "g:o:s:l:" opt
do
   case "$opt" in
      g ) parameterG="$OPTARG" ;;
      o ) parameterO="$OPTARG" ;;
      s ) parameterS="$OPTARG" ;;
      l ) parameterL="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done




# This script needs to run with R

# Settings ------------------------------------------------------------------------------

prsice_R_file='util/PRSice.R'
prsice_binary_file='util/PRSice_linux'

# space/tab deliminated summary statistics in plain text
gwas_summstats=$parameterS 

# prefix of the bed,fam,bim files
plink_files=$parameterG 

# Phenotype for MDD diagnosis: space/tab deliminated file. Columns: FID, IID, phenotype (e.g. MDD_diagnosis)
phenotype_file='data/dummy_pheno.txt'
pheno_name='dummy_pheno'

# A list of valid SNPs
ls_snp=$parameterL

# prefix for the output files
output_prefix=$parameterO 



# PRSice script:

COUNT=`wc -l $plink_files.fam | awk '{print $1}'`
if [ ${COUNT} -gt 1000 ]
   then

Rscript $prsice_R_file \
    --prsice $prsice_binary_file \
    --base $gwas_summstats \
    --target $plink_files \
    --thread 3 \
    --stat BETA \
    --binary-target T \
    --pheno $phenotype_file \
    --pheno-col $pheno_name \
    --clump-r2 0.1 \
    --bar-levels 0.00000005,0.000001,0.0001,0.001,0.01,0.05,0.1,0.2,0.5,1 \
    --fastscore \
    --print-snp \
    --all-score \
    --extract $ls_snp \
    --out $output_prefix

   else

Rscript $prsice_R_file \
    --prsice $prsice_binary_file \
    --base $gwas_summstats \
    --target $plink_files \
    --thread 3 \
    --stat BETA \
    --ld data/1000G/1000g_CEU_plink \
    --binary-target T \
    --pheno $phenotype_file \
    --pheno-col $pheno_name \
    --clump-r2 0.1 \
    --bar-levels 0.00000005,0.000001,0.0001,0.001,0.01,0.05,0.1,0.2,0.5,1 \
    --fastscore \
    --print-snp \
    --all-score \
    --extract $ls_snp \
    --out $output_prefix

fi

