#!/bin/bash
BUILDID="$1"
JENKINSJOBNAME="$2"
EXPID="$3"
SEURAT1OUTGCSBUCKET="$4"
var1=`echo "$EXPID" | awk '{print tolower($0)}'`;
expidlower=`echo "$var1" | tr '_' '-'`;
K8JOBNAME="$expidlower"-"seurat2"-"$BUILDID";
podname=`hostname`;
SEURATOUTGCSBUCKET="gs://testinggenomic/Seurat_output"
SEURAT2OUTFOLDER="seurat2out"-"$EXPID"-"$BUILDID"
rdsbasename=`basename $SEURAT1OUTGCSBUCKET`
RDSINPUTFOLDERPATH="/mounttest/$rdsbasename/"
RDSINPUTFILEPATH=`find $RDSINPUTFOLDERPATH -name *.rds`
RANDOMVALUE="$RANDOM"

if mkdir $SEURAT2OUTFOLDER && cd $SEURAT2OUTFOLDER && Rscript /mounttest/gitrepo/Seurat/Seurat2.R $RDSINPUTFILEPATH && ls && gsutil cp -r ../$SEURAT2OUTFOLDER $SEURATOUTGCSBUCKET;
then
echo "working"
mysql -h10.60.2.8 -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -e "INSERT INTO seurat2_output_details(experimentID,jenkinsjobname_buildid,k8jobname,podname,Seurat1Outputgcsbucket,Outputgcsbucket,outputfoldername,Seurat2_status) VALUES ('$EXPID','$JENKINSJOBID_$BUILDID','$K8JOBNAME','$podname','$SEURAT1OUTGCSBUCKET','$SEURATOUTGCSBUCKET/$SEURAT2OUTFOLDER','$SEURAT2OUTFOLDER','Success')";
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat2-success-notification -p buildid=$BUILDID   -p jenkinsjobID=$JENKINSJOBNAME-$BUILDID -p k8jobname=$K8JOBNAME -p podname=$podname  -p outputgcsbucket=$SEURATOUTGCSBUCKET/$SEURAT2OUTFOLDER -p seurat2outfolder=$SEURAT2OUTFOLDER 

else
echo "not working"
mysql -h10.60.2.8 -P3306 -ujenkinsuser -pjenkins123 -D tessa_output -e "INSERT INTO seurat2_output_details(experimentID,jenkinsjobname_buildid,k8jobname,podname,Seurat1Outputgcsbucket,Outputgcsbucket,outputfoldername,Seurat2_status) VALUES ('$EXPID','$JENKINSJOBID_$BUILDID','$K8JOBNAME','$podname','$RANDOMVALUE','NA','NA','Failure')";
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Seurat-failure-notification -p jenkinsjobID=$JENKINSJOBNAME-$BUILDID -p k8jobname=$K8JOBNAME -p podname=$podname

fi
