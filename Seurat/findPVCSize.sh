#!/bin/bash
#read the csv file
input="$1"
input1="sample$RANDOM.csv"

dos2unix $input
echo "dos2unix $input passed"
exec < $input || exit 1
echo "exec < $input || exit 1  passed"
awk 'NR>1' $input > $input1
cat $input1
echo "awk passed"
inputLength=`csvtool height $input1`
echo $inputLength
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
fi
done
rm output.csv
rm $input1

calPvcSize() {
arr=("$@")
declare -a pvcbuckArr=("${!1}")
len=${#arr[@]}
for opbucket in ${pvcbuckArr[@]}
do
size=`gsutil du -s $opbucket`
sizespilt="$(cut -d ' ' -f1 <<<"$size")"
let sum=$(($sum+$sizespilt))
done
sizemul=`expr $sum \* 4`
PVCSIZE=`expr $sizemul / 1073741824`
}
calPvcSize originalgcsbucArr[@]
echo $(( $PVCSIZE ))
