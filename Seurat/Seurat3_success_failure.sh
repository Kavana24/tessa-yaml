#!/bin/bash
BUILDID="$1"
JENKINSJOBNAME="$2"
EXPID="$3"
SEURAT1RDSFOLDERPATH="$4"
#SEURAT1OUTGCSBUCKET="$5"
var1=`echo "$EXPID" | awk '{print tolower($0)}'`;
expidlower=`echo "$var1" | tr '_' '-'`;
K8JOBNAME="$expidlower"-"seurat2"-"$BUILDID";
podname=`hostname`;
SEURATOUTGCSBUCKET="gs://testinggenomic/Seurat_output"
SEURAT3OUTFOLDER="seurat3out"-"$EXPID"-"$BUILDID"
RDSINPUTFILEPATH="/mounttest/$SEURAT1RDSFOLDERPATH/$EXPID.rds"

if mkdir $SEURAT3OUTFOLDER && cd $SEURAT3OUTFOLDER && mkdir CD4_renorm && Rscript /mounttest/gitrepo/Seurat/Seurat3.R $RDSINPUTFILEPATH && ls && gsutil cp -r ../$SEURAT2OUTFOLDER $SEURATOUTGCSBUCKET;
then
echo "working"
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat3-success-notification -p jenkinsjobID=$JENKINSJOBNAME-$BUILDID -p k8jobname=$K8JOBNAME -p podname=$podname -p expid=$EXPID outputgcsbucket=$SEURATOUTGCSBUCKET/$SEURAT3OUTFOLDER -p seurat3outfolder=$SEURAT3OUTFOLDER 

else

echo "not working"
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat-failure-notification -p jenkinsjobID=$JENKINSJOBID-$BUILDID -p k8jobID=seuart3-$BUILDID

fi
