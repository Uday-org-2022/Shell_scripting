#!/bin/bash
#
read -p "Enter the filename: " File

if [ -f $File ]
then
     if [ -w $File ]
     then
	 echo "Type some data of a file.To press the button CTRL +d"
	 cat >> $File
     else
	 echo The file do not have write permissions
     fi
else
echo $File does not exists
fi
