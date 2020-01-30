#!/bin/bash
md5_all="$1"
file=()
file=`awk -F ' ' '{print $2}' $md5_all`
echo $file
for f in $file;do
absolutepath=`find .. -name "$f" -exec readlink -f {} \;`
echo $absolutepath
echo $f
sed -i  "s|$f|$absolutepath|g" "$md5_all"
cat $md5_all
done
md5sum -c $md5_all
