while getopts "d:" opt
do
   case "$opt" in
      d ) parameterD="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

plink_file=$parameterD

# Check genome build ----------------------------------------------------

# Download hg19 genome build data and check

if [ ! -f "data/snp151Common.txt" ]
   then
      wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/snp151Common.txt.gz
      gunzip snp151Common.txt.gz
      mv snp151Common.txt data/
fi

if [ ! -f "data/check_genome_build.txt" ]
   then
      Rscript util/check_genome_build.R --bim $parameterD
fi

# More than 25% SNPs not presented in the reference file or 
# more than 5% presented SNPs in the wrong location 
# then exit the script

P_present=`cat data/check_genome_build.txt | grep 'present' |awk '{print $1}' `
Loc_match=`cat data/check_genome_build.txt | grep 'loc_matched' |awk '{print $1}'`

if (( $(bc <<< "$P_present<0.85") )); then
    printf 'Local genetic data is under an incompatible genome build\n'
    exit 1
fi

if (( $(bc <<< "Loc_match<0.95") )) ; then
    printf 'Local genetic data is under an incompatible genome build\n'
    exit 1
fi

# Set up   --------------------------------------------------------------
mkdir -p PRS


############################## All SNPs #################################

# Original summary statistics  ------------------------------------------

for file in $(ls summstats/*.summstats)
do
    summstats_filename=$file
    summstats_basename=$(basename ${summstats_filename} .summstats)

   ### Check if there's already an output
   if [ -f "PRS/${summstats_basename}_orig.all_scores" ]
   then
      printf "${summstats_basename}_orig.all_scores has been generated in the PRS folder\nSkip the process"
      continue
   fi

    ### Based on whether there is an .valid output:
	if [ -f "PRS/${summstats_basename}_orig.valid" ]; then
	    bash script/PREP_PRS/PRS_prsice2_TandC_validls.sh -g $plink_file \
	    -s $summstats_filename \
	    -l PRS/${summstats_basename}_orig.valid \
	    -o PRS/${summstats_basename}_orig
	else
	    bash script/PREP_PRS/PRS_prsice2_TandC.sh -g $plink_file \
	    -s $summstats_filename \
	    -o PRS/${summstats_basename}_orig
	fi

done


# SbayesR summary statistics    ----------------------------------------

for file in $(ls summstats/*.sbayesr_summstats)
do
    summstats_filename=$file
    summstats_basename=$(basename ${summstats_filename} .sbeyesr_summstats)

   ### Check if there's already an output
   if [ -f "${summstats_basename}_sbayesr.all_scores" ]
   then
      printf "${summstats_basename}_sbayesr.all_scores has been generated in the PRS folder\nSkip the process"
      continue
   fi


    ### Based on whether there is an .valid output:
	if [ -f "PRS/${summstats_basename}_sbayesr.valid" ]; then
	    bash script/PREP_PRS/PRS_prsice2_SBayesR_validls.sh -g $plink_file \
	    -s $summstats_filename \
	    -l PRS/${summstats_basename}_sbayesr.valid \
	    -o PRS/${summstats_basename}_sbayesr
	else
	    bash script/PREP_PRS/PRS_prsice2_SBayesR.sh -g $plink_file \
	    -s $summstats_filename \
	    -o PRS/${summstats_basename}_sbayesr
	fi

done


####################### SNPs across studies ############################

# Original summary statistics  ------------------------------------------

for file in $(ls summstats/*.summstats)
do
    summstats_filename=$file
    summstats_basename=$(basename ${summstats_filename} .summstats)

   ### Check if there's already an output
   if [ -f "PRS/${summstats_basename}_restrictSNP_orig.all_scores" ]
   then
      printf "${summstats_basename}_restrictSNP_orig.all_scores has been generated in the PRS folder\nSkip the process"
      continue
   fi

    ### Based on whether there is an .valid output:
	if [ -f "PRS/${summstats_basename}_restrictSNP_orig.valid" ]; then
	    bash script/PREP_PRS/PRS_prsice2_TandC_validls.sh -g $plink_file \
	    -s $summstats_filename \
	    -l PRS/${summstats_basename}_restrictSNP_orig.valid \
	    -o PRS/${summstats_basename}_restrictSNP_orig
	else
	    bash script/PREP_PRS/PRS_prsice2_TandC.sh -g $plink_file \
            -l data/SNP_list.txt \
	    -s $summstats_filename \
	    -o PRS/${summstats_basename}_restrictSNP_orig
	fi

done


# SbayesR summary statistics    ----------------------------------------

for file in $(ls summstats/*.sbayesr_summstats)
do
    summstats_filename=$file
    summstats_basename=$(basename ${summstats_filename} .sbeyesr_summstats)

   ### Check if there's already an output
   if [ -f "${summstats_basename}_restrictSNP_sbayesr.all_scores" ]
   then
      printf "${summstats_basename}_restrictSNP_sbayesr.all_scores has been generated in the PRS folder\nSkip the process"
      continue
   fi


    ### Based on whether there is an .valid output:
	if [ -f "PRS/${summstats_basename}_restrictSNP_sbayesr.valid" ]; then
	    bash script/PREP_PRS/PRS_prsice2_SBayesR_validls.sh -g $plink_file \
	    -s $summstats_filename \
	    -l PRS/${summstats_basename}_restrictSNP_sbayesr.valid \
	    -o PRS/${summstats_basename}_restrictSNP_sbayesr
	else
	    bash script/PREP_PRS/PRS_prsice2_SBayesR.sh -g $plink_file \
            -l data/SNP_list.txt \
	    -s $summstats_filename \
	    -o PRS/${summstats_basename}_restrictSNP_sbayesr
	fi

done

