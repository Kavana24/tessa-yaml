#!/bin/bash
input="$1"
input1="sample3.csv"
dos2unix $input
exec < $input || exit 1
awk 'NR>1' $input > $input1
while IFS=',' read -r heading1 heading2 heading3 heading4 <&3;
do
id="$heading1"
transcriptome="$heading2"
fastqs="$heading3"
sample="$heading4"
gcsbucket="$heading5"
sample1=`echo $sample | sed 's/"""//g'`
echo id = $id
echo transcriptome = $transcriptome
echo fastqs = $fastqs
#echo sample = $sample
echo sample1 = $sample1
echo gcsbucket = $gcsbucket
size1=`gsutil du -s $gcsbucket`
echo $size1
sizespilt="$(cut -d ' ' -f1 <<<"$size1")"
sizemul=`expr $sizespilt \* 4`
PVCSIZE=`expr $sizemul / 1073741824`
echo $PVCSIZE
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build  Cellranger-pipeline -p size=$PVCSIZE -p id=$id -p transcriptome=$transcriptome -p sample=$sample1 -p fastqs=$fastqs -p gcsbucket=$gcsbucket
done 3< "$input1"
rm sample3.csv

