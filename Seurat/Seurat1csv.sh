#!/bin/bash
input="$1"
input1="sample$RANDOM.csv"
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

        if [ $outputbucketvalue -eq 1 ]
                then
                sampleID=`mysql -hseurat-test -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -B -N -e "Select Sample_ID_BuildID  from cellranger_new_output_details where Outputgcsbucket = '$outputgcsbucket'";`
                expidnew=`mysql -hseurat-test -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -B -N -e "Select ExperimentID  from cellranger_new_output_details where Outputgcsbucket = '$outputgcsbucket'";`
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
seurat(){
        arr=("$@")
                declare -a IDArr=("${!1}")
        declare -a BucketArr=("${!2}")
        len=${#IDArr[@]}
for ((i=0; i<$len; i++))
                do
                echo "${IDArr[i]} <- Read10X(data.dir=\"$"{BucketArr[i]}"\")"
        done
        for ((j=0; j<$len; j++))
                do
                echo "${IDArr[j]} <- CreateSeuratObject(counts=${IDArr[j]}, project=\""${IDArr[j]}"\")"
        done

        if [ $len -eq 2 ]
        then
                for ((k=0; k<$len-1; k++))
                        do
                       # echo "$expidnew inside for loop"
                        echo "dat_1 <- merge(${IDArr[k]}, y=${IDArr[k+1]}, add.cell.ids=c(\""${IDArr[k]}"\",\""${IDArr[k+1]}"\"),project=\""project-name"\")"
                done
        else
                xstring=${IDArr[0]}
                for ((i=1; i<$len; i++))
                        do
                        initystring=$initystring"${IDArr[i]},"
                        ystring=`echo $initystring | sed 's/,$//'`
                done
                for ((j=0; j<$len; j++))
                        do
                        initaddcellstring=$initaddcellstring\""${IDArr[j]}"\",
                        addcellstring=`echo $initaddcellstring | sed 's/,$//'`
                done
                echo "dat_1 <- merge(x = $xstring, y = c($ystring), add.cell.ids=c($addcellstring), project=\""project-name"\")"
        fi
}
Rscript="Seurat$RANDOM.txt"
seurat sampleIdArr[@] opGcsArr[@]  > $Rscript
sed -i "3r $Rscript" /mounttest/gitrepo/Seurat/Seurat1.R
`sed -i 's/project-name/'$expidnew'/g' Seurat.R`
bucketcopy() {
declare -a copybuckArr=("${!1}")
for bucket in ${copybuckArr[@]}
        do
        `gsutil cp -r $bucket /mounttest/`
        done
}
#echo $expid
bucketcopy originalgcsbucArr[@]
rm $Rscript
    
