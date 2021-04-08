
plink_file = $1

# Set up   --------------------------------------------------------------
mkdir PRS

# Original summary statistics  ------------------------------------------

for file in $(ls summstats/*.summstats)
do
    summstats_filename=$file
    basename=$(basename ${input_basename} .summstats)

    bash script/PREP_PRS/PRS_prsice2_TandC.sh -g $plink_file \
    -s $summstats_filename \
    -o PRS/$basename_orig
done


# SbayesR summary statistics    ----------------------------------------

for file in $(ls summstats/*.sbayesr_summstats)
do
    summstats_filename=$file
    basename=$(basename ${input_basename} .sbeyesr_summstats)

    bash script/PREP_PRS/PRS_prsice2_SBayesR.sh -g $plink_file \
    -s $summstats_filename \
    -o PRS/$basename_sbayesr
done



