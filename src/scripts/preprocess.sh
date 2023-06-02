#!/usr/bin/env bash

plink --bfile ppmi_data/IMMUNO \
    --bmerge ppmi_data/NEUROX.bed ppmi_data/NEUROX.bim ppmi_data/NEUROX.fam \
    --keep-allele-order \
    --make-bed \
    --out temp/ppmi

plink --bfile temp/ppmi \
    --keep-allele-order \
    --extract assets/snp_list.txt \
    --keep assets/sample_list.txt \
    --make-bed \
    --out temp/ppmi_filtered

echo '"iid","pheno"' > temp/phenotypes.csv
cat assets/sample_list.txt \
    | awk '{print $1}' \
    | xargs -I '{}' grep '"{}"' ppmi_data/Participant_Status.csv \
    | cut -d, -f1,3 >> temp/phenotypes.csv