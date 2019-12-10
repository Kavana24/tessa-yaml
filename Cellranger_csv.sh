#!/bin/bash
input="$1"


exec < $input || exit 1
read header # read (and ignore) the first line
while IFS=, read heading1 heading2 heading3 heading4 heading5; do
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
    size=`gsutil du -s $gcsbucket`
    gsutil ls
    echo $size
    sizespilt="$(cut -d ' ' -f1 <<<"$size")"
    sizemul=`expr $sizespilt \* 2`
    PVCSIZE=`expr $sizemul / 1073741824`
    echo $PVCSIZE
	    
#java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build cellranger-pipeline -p size=$PVCSIZE -p id=$id -p transcriptome=$transcriptome -p sample=$sample1 -p fastqs=$fastqs -p gcsbucket=$gcsbucket
	
done
