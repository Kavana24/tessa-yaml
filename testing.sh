#!/bin/sh
sleep 20s
echo "Print this $BUILD_ID" >> $WORKSPACE/print.txt
cat $WORKSPACE/print.txt
