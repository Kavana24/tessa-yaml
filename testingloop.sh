#!/bin/bash
 x=1
 i=1
while [ $x -le 3 ]
do
timestamp=$(date +%s)
echo $timestamp
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build cellranger-pipeline -p size=$PVCSIZE -p id=$id -p transcriptome=$transcriptome -p sample=$sample1 -p fastqs=$fastqs  -p gcsbucket=$gcsbucket
x=$(($x+1))
echo $i
i=$(($i+1))
timestamp=$(date +%s)
echo $timestamp
done
