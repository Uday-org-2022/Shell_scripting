#!/bin/bash
#
read -p "Enter the filename: " filename

if [ -e $filename ]
then
echo $filename is found
else
echo $filename not found
fi
