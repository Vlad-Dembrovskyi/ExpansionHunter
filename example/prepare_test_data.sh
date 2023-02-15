#!/bin/bash
set -uxe

TAG='v5.0.0'

# This script downloads the ExpansionHunter test data from:
# https://github.com/Illumina/ExpansionHunter/tree/${TAG}/example/input

mkdir -p test_data
cd test_data
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/input/reference.fa
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/input/variants.bam
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/input/variants.bam.bai
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/${TAG}/example/input/variants.json

# build some extra indicies to prove multiple routes, the expansion hunter image works well for this
docker pull quay.io/wtsicgp/expansion_hunter:5.0.0

## adds csi index to files
docker run -u $(id -u ${USER}):$(id -g ${USER}) -v $PWD:/d:rw --rm quay.io/wtsicgp/expansion_hunter:5.0.0 samtools index -c /d/variants.bam
## create cram input
docker run -u $(id -u ${USER}):$(id -g ${USER}) -v $PWD:/d:rw --rm quay.io/wtsicgp/expansion_hunter:5.0.0 samtools view -T /d/reference.fa -C -o /d/variants.cram /d/variants.bam
docker run -u $(id -u ${USER}):$(id -g ${USER}) -v $PWD:/d:rw --rm quay.io/wtsicgp/expansion_hunter:5.0.0 samtools index /d/variants.cram

## now prepare expansion hunter inputs
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats.vcf
curl -sSLO https://github.com/Illumina/ExpansionHunter/raw/v5.0.0/example/output/repeats_realigned.bam
echo 'ATXN7\nATXN8OS' > multi_str.txt
echo 'chr1_44835_44867 chr1 44835\nchr1_151101_151105 chr1 151101\nchr1_165954_165962 chr1 165954' > repeats.txt
