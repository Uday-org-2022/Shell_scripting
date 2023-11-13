#!/bin/bash
#
read -p "Enter the filename: " filename

if [ -w $filename ]
then
echo The given file has write access
else
echo The given file does not has write access
fi
