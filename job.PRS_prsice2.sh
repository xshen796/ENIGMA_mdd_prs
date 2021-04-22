while getopts "d:" opt
do
   case "$opt" in
      d ) parameterD="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

plink_file=$parameterD


# Set up   --------------------------------------------------------------
mkdir -p PRS

# Original summary statistics  ------------------------------------------

for file in $(ls summstats/*.summstats)
do
    summstats_filename=$file
    summstats_basename=$(basename ${summstats_filename} .summstats)

   ### Check if there's already an output
   if [ -f "PRS/${summstats_basename}_orig.all_scores" ]
   then
      echo "${summstats_basename}_orig.all_scores has been generated in the PRS folder\nSkip the process"
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
      echo "${summstats_basename}_sbayesr.all_scores has been generated in the PRS folder\nSkip the process"
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


    bash script/PREP_PRS/PRS_prsice2_SBayesR.sh -g $plink_file \
    -s $summstats_filename \
    -o PRS/${summstats_basename}_sbayesr
done



