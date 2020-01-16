#!/bin/bash
input="$1"
input1="sample$opGcsArrRANDOM.csv"
dos2unix $input
exec < $input || exit 1
awk 'NR>1' $input > $input1
inputLength=`csvtool height $input1`
declare -a sampleIdArr
declare -a opGcsArr
declare -a originalgcsbucArr
for ((i=0; i<$inputLength ; i++))
do
csvtool drop $i $input1 | csvtool take 1 - > output.csv
expid=`csvtool format '%(1)\n' output.csv`
outputgcsbucket=`csvtool format '%(2)\n' output.csv`
outputbucketvalue=`mysql -hseurat-test -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -B -N -e "Select count(Outputgcsbucket) from cellranger_new_output_details where Outputgcsbucket='$outputgcsbucket' AND Cellranger_status = 'Success' AND ApprovalStatus = 'Approved'";`
#echo $outputbucketvalue
if [ $outputbucketvalue -eq 1 ]
then
sampleID=`mysql -hseurat-test -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -B -N -e "Select Sample_ID_BuildID  from cellranger_new_output_details where Outputgcsbucket = '$outputgcsbucket'";`

sampleIdArr=("${sampleIdArr[@]}" "$sampleID")

originalgcsbucArr=("${originalgcsbucArr[@]}" "$outputgcsbucket")
opgcsbase=`basename $outputgcsbucket`;

alteredopgcs="/mounttest/"$opgcsbase"/outs/filtered_feature_bc_matrix"

opGcsArr=("${opGcsArr[@]}" "$alteredopgcs")
else
echo "Output GCS bucket not present in Cellranger Output table"
fi
done
printf '%s\n'  "${sampleIdArr[@]}";
printf '%s\n'  "${opGcsArr[@]}";
rm output.csv
rm $input1

function seurat() {
   arr=("$@")
   len=${#sampleIdArr[@]}
for ((i=0; i<$len; i++))
do
echo "${sampleIdArr[i]} <- Read10X(data.dir=\""${opGcsArr[i]}"\")"
done
for ((j=0; j<$len; j++))
do


echo "${sampleIdArr[j]} <- CreateSeuratObject(counts=${sampleIdArr[j]}, project=\""${sampleIdArr[j]}"\")"

done
for ((k=0; k<$len-1; k++))
do
echo "dat_1 <- merge(${sampleIdArr[k]}, y=${sampleIdArr[k+1]}, add.cell.ids=c(\""${sampleIdArr[k]}"\",\""${sampleIdArr[k+1]}"\"), project=\"""Taka_HER2CAR""\")"
done
}
Rscript="Seurat$RANDOM.txt"
seurat "${sampleIdArr[@]} ${opGcsArr[@]}" > $Rscript
sed -i '3r Seuratnew.txt' Seurat.R

function bucketcopy() {
arr=("$1")
for bucket in $arr
do
echo $bucket
`gsutil cp -r $bucket mountest/`
done
}
bucketcopy "${originalgcsbucArr[@]}"
