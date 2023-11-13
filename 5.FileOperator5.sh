#!/bin/bash
#
read -p "Enter the filename: " filename

if [ -x $filename ]
then
echo The given file has execute access
else
echo The given file does not has execute access
fi
