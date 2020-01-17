#!/bin/bash
#read the csv file
input="$1"
input1="sample$opGcsArrRANDOM.csv"
dos2unix $input
exec < $input || exit 1
awk 'NR>1' $input > $input1
inputLength=`csvtool height $input1`
declare -a sampleIdArr
declare -a originalgcsbucArr
sum=0
for ((i=0; i<$inputLength ; i++))
do
csvtool drop $i $input1 | csvtool take 1 - > output.csv
expid=`csvtool format '%(1)\n' output.csv`
outputgcsbucket=`csvtool format '%(2)\n' output.csv`
outputbucketvalue=`mysql -hseurat-test -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -B -N -e "Select count(Outputgcsbucket) from cellranger_new_output_details where Outputgcsbucket='$outputgcsbucket' AND Cellranger_status = 'Success' AND ApprovalStatus = 'Approved'";`
if [ $outputbucketvalue -eq 1 ]
then
sampleID=`mysql -hseurat-test -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -B -N -e "Select Sample_ID_BuildID  from cellranger_new_output_details where Outputgcsbucket = '$outputgcsbucket'";`

sampleIdArr=("${sampleIdArr[@]}" "$sampleID")

originalgcsbucArr=("${originalgcsbucArr[@]}" "$outputgcsbucket")
#else
#echo "Output GCS bucket not present in Cellranger Output table"
fi
done
#printf '%s\n'  "${sampleIdArr[@]}";
#printf '%s\n'  "${originalgcsbucArr[@]}";
rm output.csv
rm $input1

function calPvcSize() {

arr=("$@")
#echo "${arr[@]}"
len=${#arr[@]}
#echo $len
for opbucket in ${arr[@]}
do
size=`gsutil du -s $opbucket`
#echo $size
sizespilt="$(cut -d ' ' -f1 <<<"$size")"
#echo splitsize $sizespilt
let sum=$(($sum+$sizespilt))
#echo sum $sum
done
sizemul=`expr $sum \* 4`
PVCSIZE=`expr $sizemul / 1073741824`
#echo $PVCSIZE
}
calPvcSize "${originalgcsbucArr[@]}"
echo $(( $PVCSIZE ))
