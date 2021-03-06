while getopts ":d:" opt
do
   case "$opt" in
      d ) parameterD="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done


##############################     Prep    #################################


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

# Check list for files to expect  ---------------------------------------

if [ ! -f "data/local_checklist" ]
   then
      Rscript util/create_checkls.R --plink $parameterD
      echo 'DONE: check list created in data/local_checklist' >> PRS/log.txt
   else
      echo 'DONE: data/local_checklist already exists' >> PRS/log.txt
fi


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

# More than 25% SNPs of local SNPs not found in the reference file or 
# more than 10% presented SNPs in the wrong location 
# then exit the script

P_present=`cat data/check_genome_build_${base_file}.txt | grep 'present' |awk '{print $1}' `
Loc_match=`cat data/check_genome_build_${base_file}.txt | grep 'loc_matched' |awk '{print $1}'`

if (( $(bc <<< "$P_present<0.75") )); then
    printf 'QUIT: Local genetic data is under an incompatible genome build\n'
    echo 'FAIL: incompatible genome build' >> PRS/log.txt
    exit 1
fi

if (( $(bc <<< "$Loc_match<0.90") )); then
    printf 'QUIT: Local genetic data is under an incompatible genome build\n'
    echo 'FAIL: incompatible genome build' >> PRS/log.txt
    exit 1
fi

echo 'DONE: check genome build' >> PRS/log.txt

# Calculate GRM   ----------------------------------------------------

if [ ! -f "PRS/${base_file}.grm.bin" ]
  then
	util/gcta_1.93.2beta/gcta64 --bfile $plink_file --maf 0.01 --make-grm  --out PRS/$base_file
fi

if [ -f "PRS/${base_file}.grm.bin" ]
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

# Unzip SNP lists
if [ -f "data/site*.gz" ]
   then
	gunzip data/site*.gz
fi

while read -r a b c || [ -n "$a" ]; do

   ### Read inputs   
   snplist=$a
   summstats_filename=$b
   summstats_basename=$(basename ${summstats_filename} .summstats)
   prs_method=$c
   # unique file name for the inputs
   opt_fname="${summstats_basename}_$(basename $snplist)_${prs_method}"

   ### Check if there's already an output
    if [ -f "PRS/${opt_fname}.all_score" ]
    then
       printf "${opt_fname}.all_score has been generated in the PRS folder\nSkip the process\n\n"
       echo "DONE: ${opt_fname}.all_score already exists" >> PRS/log.txt
       continue
    fi

   ### Based on the combinations
    run_count=0

	if [ ! -f "PRS/${opt_fname}.valid" ]&&[ $prs_method = "CT" ]; then
	    bash script/PREP_PRS/PRS_prsice2_TandC.sh -g $plink_file \
	    -s $summstats_filename \
	    -o PRS/${opt_fname}

             if [ -f "PRS/${opt_fname}.all_score" ]; then
               echo "DONE: ${opt_fname}.all_score generated (original SNP list + CT method)" >> PRS/log.txt
	    else
               echo "FAIL: ${opt_fname}.all_score not generated (skip process to include a valid SNP list generated by PRSice; CT method)" >> PRS/log.txt
             fi

	else
             let run_count+=1
	fi


	if [ -f "PRS/${opt_fname}.valid" ]&&[ $prs_method = "CT" ]; then
	    bash script/PREP_PRS/PRS_prsice2_TandC_validls.sh -g $plink_file \
	    -s $summstats_filename \
	    -l PRS/${opt_fname}.valid \
	    -o PRS/${opt_fname}

             if [ -f "PRS/${opt_fname}.all_score" ]; then
             echo "DONE: ${opt_fname}.all_score generated (PRSice generated valid SNP list + CT method)" >> PRS/log.txt
             fi
	else
             let run_count+=1
	fi

	if [ ! -f "PRS/${opt_fname}.valid" ]&&[ $prs_method = "sbayesr" ]; then
	    bash script/PREP_PRS/PRS_prsice2_SBayesR.sh -g $plink_file \
	    -s $summstats_filename \
	    -o PRS/${opt_fname}

             if [ -f "PRS/${opt_fname}.all_score" ]; then
                echo "DONE: ${opt_fname}.all_score generated (original SNP list + SBayesR method)" >> PRS/log.txt
 	    else
               echo "FAIL: ${opt_fname}.all_score not generated (skip process to include a valid SNP list generated by PRSice; SBayesR method)" >> PRS/log.txt

             fi

	else
             let run_count+=1
	fi

	if [ -f "PRS/${opt_fname}.valid" ]&&[ $prs_method = "sbayesr" ]; then
             bash script/PREP_PRS/PRS_prsice2_SBayesR_validls.sh -g $plink_file \
	    -s $summstats_filename \
	    -l PRS/${opt_fname}.valid \
	    -o PRS/${opt_fname}
             
             if [ -f "PRS/${opt_fname}.all_score" ]; then
             echo "DONE: ${opt_fname}.all_score generated (PRSice generated SNP list + SBayesR method)" >> PRS/log.txt
             fi

	else
             let run_count+=1
	fi

   ### Check if anything run at all
     echo "Run count (missed): ${run_count}"
     if [ $run_count -eq 4 ]&&[ ! -f "PRS/${opt_fname}.all_score" ]; then
         echo "FAIL: no PRS generated for ${a} + ${b} using the ${c} method"
         exit 1
     fi
       
done < data/input.txt


############################## Check outputs #################################

Rscript util/check_files_toreturn.R --checklist PRS/local_checklist

N_missing_score=`wc -l data/missing_score | awk '{print $1}' `

if [ $N_missing_score = 0 ]; then
      printf 'FINISH: all scores generated\n'
      echo 'DONE: all scores generated' >> PRS/log.txt
    else
      printf 'WARNING: following scores are not generated\n'
      cat data/missing_score
      echo 'FAIL: filess not generated:' >> PRS/log.txt
      cat data/missing_score >> PRS/log.txt
fi