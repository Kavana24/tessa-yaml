#!/bin/sh
sleep 20s
echo "Print this  $BUILDID" >> $WORKSPACE/print.txt
cat $WORKSPACE/print.txt
