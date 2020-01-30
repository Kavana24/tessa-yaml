#!/bin/bash
BUILDID="$1"
EXPID="$7"
JENKINSJOBID="$2"
ID="$3"
TRANSCRIPTOME="$4"
FASTQS="$6"

#to obtain the values of sample when not provided in csv
#cd $FASTQS
#SAMPLE=`find . -type f -iname "*.fastq.gz" -exec basename "{}" \; | cut -d'_' -f 1-3 | sort -u | tr "\n" "," | sed 's/,$/ /' | tr " " "\n"`

SAMPLE="$5"
id="$ID"_"$BUILDID";
podname=`hostname`;
var1=`echo "$EXPID" | awk '{print tolower($0)}'`;
expidlower=`echo "$var1" | tr '_' '-'`;
var2=`echo "$ID" | awk '{print tolower($0)}'`;
idlower=`echo "$var2" | tr '_' '-'`;
k8jobname="$expidlower"-"$idlower"-cellranger-"$BUILDID";

#i=1;
#if [ $i -eq 2 ]

if cellranger count --id=$id --transcriptome=$TRANSCRIPTOME --sample=$SAMPLE --fastqs=$FASTQS && ls && gsutil cp -r $id gs://testinggenomic/Cellranger_output ;
#if cellranger testrun --id=tiny
then
echo "working"
df -h
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Cellranger-success-notification -p jenkinsjobID=$JENKINSJOBID-$BUILDID -p k8jobID=$k8jobname -p outputgcsbucket=gs://testinggenomic/Cellranger_output/$id -p id=$id -p Experiment_ID=$EXPID -p Podname=$podname
else
echo "wrong"
df -h
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Cellranger-failure-notification -p jenkinsjobID=$JENKINSJOBID-$BUILDID -p k8jobID=$k8jobname -p id=$id -p Experiment_ID=$EXPID -p Podname=$podname
fi
