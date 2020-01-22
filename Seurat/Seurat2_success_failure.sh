#!/bin/bash
BUILDID="$1"
JENKINSJOBNAME="$2"
EXPID="$3"
RDSINPUTFILEPATH="$4"
var1=`echo "$EXPID" | awk '{print tolower($0)}'`;
expidlower=`echo "$var1" | tr '_' '-'`;
K8JOBNAME="$expidlower"-"seurat2"-"$BUILDID";
podname=`hostname`;
SEURATOUTGCSBUCKET="gs://testinggenomic/Seurat_output"
SEURAT2OUTFOLDER="seurat2out"-"$EXPID"-"$BUILDID"

if mkdir $SEURAT2OUTFOLDER && cd $SEURAT2OUTFOLDER && Rscript /mounttest/gitrepo/Seurat/Seurat2.R $RDSINPUTFILEPATH ; ls ; gsutil cp -r ../$SEURAT2OUTFOLDER $SEURATOUTGCSBUCKET;
then
echo "working"
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat2-success-notification -p jenkinsjobID=$JENKINSJOBNAME-$BUILDID -p k8jobname=$K8JOBNAME -p podname=$podname -p expid=$EXPID outputgcsbucket=$SEURATOUTGCSBUCKET/$SEURAT2OUTFOLDER -p seurat2outfolder=$SEURAT2OUTFOLDER 

else

echo "not working"
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat-failure-notification -p jenkinsjobID=$JENKINSJOBNAME-$BUILDID -p k8jobID=$K8JOBNAME

fi
