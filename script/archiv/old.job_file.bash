while getopts "d:" opt
do
   case "$opt" in
      d ) parameterD="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

plink_file=$parameterD

# Set up folders and logging process ------------------------------------
mkdir -p PRS

if [ ! -f "PRS/log.txt" ]
   then
     touch PRS/log.txt
fi

echo '------------------------   START    ------------------------' >> PRS/log.txt

echo $(date) >> PRS/log.txt
base_file=$(basename $plink_file)

# Check genome build ----------------------------------------------------

# Download hg19 genome build data and check

if [ ! -f "data/snp151Common.txt" ]
   then
      wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/snp151Common.txt.gz
      gunzip snp151Common.txt.gz
      mv snp151Common.txt data/
      echo 'DONE: download snp151Common.txt' >> PRS/log.txt
   else
      echo 'DONE: snp151Common.txt already exists' >> PRS/log.txt
fi

if [ ! -f "data/check_genome_build_${base_file}.txt" ]
   then
      Rscript util/check_genome_build.R --bim $parameterD
fi

# More than 25% SNPs not presented in the reference file or 
# more than 5% presented SNPs in the wrong location 
# then exit the script

P_present=`cat data/check_genome_build_${base_file}.txt | grep 'present' |awk '{print $1}' `
Loc_match=`cat data/check_genome_build_${base_file}.txt | grep 'loc_matched' |awk '{print $1}'`

if (( $(bc <<< "$P_present<0.85") )); then
    printf 'Local genetic data is under an incompatible genome build\n'
    echo 'FAIL: incompatible genome build' >> PRS/log.txt
    exit 1
fi

if (( $(bc <<< "Loc_match<0.95") )) ; then
    printf 'Local genetic data is under an incompatible genome build\n'
    echo 'FAIL: incompatible genome build' >> PRS/log.txt
    exit 1
fi

echo 'DONE: check genome build' >> PRS/log.txt

# Calculate GRM   ----------------------------------------------------

if [ ! -f "PRS/${base_file}.grm.id" ]
  then
	util/gcta_1.93.2beta/gcta64 --bfile $plink_file --maf 0.01 --make-grm  --out PRS/$base_file
fi

if [ -f "PRS/${base_file}.grm.id" ]
   then
      echo 'DONE: generate GRM' >> PRS/log.txt
   else
      printf 'Failed to generate GRM\n'
      echo 'FAIL: generate GRM' >> PRS/log.txt
      exit 1
fi



############################## Calculate PRS #################################

# Read inputs from file 'data/input.txt'. 
# Each line includes three inputs: 1) file name for SNP list [a], 2) file name for summstats [b] and 3) whether the summstats is a C+T method summary stats or an SBayesR summstats [c].


while read -r a b c || [ -n "$a" ]; do

   ### Read inputs   

   snplist=$a
   summstats_filename=$b
   summstats_basename=$(basename ${summstats_filename} .summstats)
   prs_method=$c
   # unique file name for the inputs
   opt_fname="${summstats_basename}_$(basename $snplist)_${prs_method}"

   ### Check if there's already an output
    if [ -f "PRS/${opt_fname}.all_scores" ]
    then
       printf "${opt_fname}.all_scores has been generated in the PRS folder\nSkip the process"
       echo "DONE: ${opt_fname}.all_scores already exists" >> PRS/log.txt
       continue
    fi

   ### Based on the combinations
    run_count=0
	if [ -f "PRS/${opt_fname}.valid" ]&&[prs_method=="CT"]; then
	    bash script/PREP_PRS/PRS_prsice2_TandC_validls.sh -g $plink_file \
	    -s $summstats_filename \
	    -l PRS/${opt_fname}.valid \
	    -o PRS/${opt_fname}
             echo "DONE: ${opt_fname}.all_scores generated" >> PRS/log.txt
	else
             run_count=run_count+1
	fi

	if [ ! -f "PRS/${opt_fname}.valid" ]&&[prs_method=="CT"]; then
	    bash script/PREP_PRS/PRS_prsice2_TandC.sh -g $plink_file \
	    -s $summstats_filename \
	    -o PRS/${opt_fname}
             echo "DONE: ${opt_fname}.all_scores generated" >> PRS/log.txt
	else
             run_count=run_count+1
	fi

	if [ -f "PRS/${opt_fname}.valid" ]&&[prs_method=="sbayesr"]; then
             bash script/PREP_PRS/PRS_prsice2_SBayesR_validls.sh -g $plink_file \
	    -s $summstats_filename \
	    -l PRS/${opt_fname}.valid \
	    -o PRS/${opt_fname}
             echo "DONE: ${opt_fname}.all_scores generated" >> PRS/log.txt
	else
             run_count=run_count+1
	fi

	if [ ! -f "PRS/${opt_fname}.valid" ]&&[prs_method=="sbayesr"]; then
	    bash script/PREP_PRS/PRS_prsice2_SBayesR.sh -g $plink_file \
	    -s $summstats_filename \
	    -o PRS/${opt_fname}
             echo "DONE: ${opt_fname}.all_scores generated" >> PRS/log.txt
	else
             run_count=run_count+1
	fi

   ### Check if anything run at all
     if [ run_count==4]&&[ ! -f "PRS/${opt_fname}.all_scores" ]; then
         echo "FAIL: no PRS generated for ${a} + ${b} using the ${c} method"
         exit 1
     fi
       

done < data/input.txt







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

   ### Check if there's an output already
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

