#!/bin/bash
 x=1
 i=1
while [ $x -le 3 ]
do
timestamp=$(date +%s)
echo $timestamp
java -jar /jenkins-cli.jar -s http://10.60.2.9:8080/ -auth admin:admin build Testing_jenkins_cli -p param1=hello
x=$(($x+1))
echo $i
i=$(($i+1))
timestamp=$(date +%s)
echo $timestamp
done
