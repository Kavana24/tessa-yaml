#!/bin/bash
input="$1"

dos2unix $input
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
    size1=`gsutil du -s $gcsbucket`
    echo $size1
    sizespilt="$(cut -d ' ' -f1 <<<"$size1")"
    sizemul=`expr $sizespilt \* 4`
    PVCSIZE=`expr $sizemul / 1073741824`
    echo $PVCSIZE
    java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Testing_jenkins_cli -p param1=hello
done
