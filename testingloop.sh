#!/bin/bash
 x=1
 i=1
while [ $x -le 3 ]
do
#timestamp=$(date +%s)
#echo $timestamp
#java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build cellranger-pipeline -p size=100 -p id=1k_PBMC_PUC1 -p transcriptome=/mounttest/PUC_test/reference/refdata-cellranger-GRCh38-3.0.0 -p sample="pbmc_1k_v3" -p fastqs=/mounttest/PUC_test/pbmc_1k_v3_fastqs  -p gcsbucket=gs://testinggenomic/PUC_test
$x=$(($x+1))
echo $x
#echo $i
$i=$(($i+1))
#timestamp=$(date +%s)
echo $i
done
