#!/bin/bash
BUILDID="$1"
echo $BUILDID
JENKINSJOBID="$2"
EXPID="$3"
var1=`echo "$EXPID" | awk '{print tolower($0)}'`;
expidlower=`echo "$var1" | tr '_' '-'`;
K8JOBNAME="$expidlower"-"seurat1"-"$BUILDID";
podname=`hostname`;
jenkinsjobid_buildid="$JENKINSJOBID"-"$BUILDID"
SEURATOUTGCSBUCKET="gs://testinggenomic/Seurat_output"
SEURATOUTFOLDER="seurat1out"-"$EXPID"-"$BUILDID"
RANDOMVALUE=`date +%s|sha256sum|base64|head -c 32`
echo $RANDOMVALUE
#RANDOMVALUE="1234567"
if mkdir $SEURATOUTFOLDER && cd $SEURATOUTFOLDER &&  Rscript /mounttest/gitrepo/Seurat/Seurat1.R && gsutil cp -r ../$SEURATOUTFOLDER $SEURATOUTGCSBUCKET ;
then
echo "Seurat1 Success"
mysql -h10.60.2.8 -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -e "INSERT INTO seurat1_output_details(experimentID,jenkinsjobname_buildid,k8jobname,podname,Outputgcsbucket,outputfoldername,Seurat1_status) VALUES ('$EXPID','$jenkinsjobid_buildid','$K8JOBNAME','$podname','$SEURATOUTGCSBUCKET/$SEURATOUTFOLDER','$SEURATOUTFOLDER','Success')";
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat1-success-notification -p jenkinsjobID=$JENKINSJOBID -p buildid=$BUILDID -p outputgcsbucket=$SEURATOUTGCSBUCKET/$SEURATOUTFOLDER -p seurat1outfolder=$SEURATOUTFOLDER -p k8jobname=$K8JOBNAME -p podname=$podname -p expid=$EXPID -p Seurat1-BuildID=$BUILDID
else
echo "Seurat1 Failure"
mysql -h10.60.2.8 -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -e "INSERT INTO seurat1_output_details(experimentID,jenkinsjobname_buildid,k8jobname,podname,Outputgcsbucket,outputfoldername,Seurat1_status) VALUES ('$EXPID','$jenkinsjobid_buildid','$K8JOBNAME','$podname','$RANDOMVALUE','NA','Failure')";
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat-failure-notification -p jenkinsjobID=$JENKINSJOBID-$BUILDID -p k8jobname=$K8JOBNAME -p podname=$podname -p Seurat1-BuildID=$BUILDID
fi
