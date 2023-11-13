#!/bin/bash
#
read -p "Enter the filename: " filename

if [ -s $filename ]
then
echo The given file $filename is not empty
else
echo The given file $filename is  empty
fi
