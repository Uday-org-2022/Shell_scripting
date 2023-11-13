#!/bin/bash
#
read -p "Enter the filename: " filename

if [ -r $filename ]
then
echo The given file has read access
else
echo The given file does not has read access
fi
