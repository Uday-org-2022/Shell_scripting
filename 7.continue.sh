#!/bin/bash
#
for (( i=1; i<=10; i++ ))
do
   if [ $i -eq 4 -o $i -eq 6 ]
   then
      continue
   fi
   echo $i
done
