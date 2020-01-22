#!/bin/bash
BUILDID="$1"
echo $BUILDID
JENKINSJOBID="$2"
EXPID="$3"
var1=`echo "$EXPID" | awk '{print tolower($0)}'`;
expidlower=`echo "$var1" | tr '_' '-'`;
K8JOBNAME="$expidlower"-"seurat1"-"$BUILDID";
podname=`hostname`;
SEURATOUTGCSBUCKET="gs://testinggenomic/Seurat_output"
SEURATOUTFOLDER="seurat1out"-"$EXPID"-"$BUILDID"

if mkdir $SEURATOUTFOLDER && cd $SEURATOUTFOLDER &&  Rscript /mounttest/gitrepo/Seurat/Seurat1.R && gsutil cp -r ../$SEURATOUTFOLDER $SEURATOUTGCSBUCKET ;
then
echo "working"
mysql -hseurat-test -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -e "INSERT INTO seurat1_output_details(experimentID,jenkinsjobname_buildid,k8jobname,podname,Outputgcsbucket,outputfoldername,Seurat1_status,ApprovalStatus) VALUES ('$EXPID','$JENKINSJOBID_$BUILDID','$K8JOBNAME','$podname','$SEURATOUTGCSBUCKET/$SEURATOUTFOLDER','$SEURATOUTFOLDER','Success','Denied')";
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat1-success-notification -p jenkinsjobID=$JENKINSJOBID -p buildid=$BUILDID -p outputgcsbucket=$SEURATOUTGCSBUCKET/$SEURATOUTFOLDER -p seurat1outfolder=$SEURATOUTFOLDER -p k8jobname=$K8JOBNAME -p podname=$podname -p expid=$EXPID
else
echo "not working"
mysql -hseurat-test -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -e "INSERT INTO seurat1_output_details(experimentID,jenkinsjobname_buildid,k8jobname,podname,Outputgcsbucket,outputfoldername,Seurat1_status,ApprovalStatus) VALUES ('$EXPID','$JENKINSJOBID_$BUILDID','$K8JOBNAME','$podname','NA','NA','Failure','Denied')";
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat-failure-notification -p jenkinsjobID=$JENKINSJOBID-$BUILDID -p k8jobID=seuart1-$BUILDID
fi
