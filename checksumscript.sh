#!/bin/bash

checkdir="/root/checksumandclam/testchecksum"
input="$1"
input1="checksumnew.csv"
exec < $input || exit 1
awk 'NR>1' $input > $input1
while IFS=',' read -r filename checksum <&3;
do
filename="$filename"
#echo $filename
oldchecksum="$checksum"
echo $oldchecksum
fullpath=`echo "$checkdir/$filename"`
if test -f "$fullpath" && echo "$oldchecksum $checkdir/$filename" | md5sum -c -
then
echo "checksums match"
else
echo "checksums do not match"
fi
done 3<"$input1"
rm $input1
