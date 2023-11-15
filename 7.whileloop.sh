#!/bin/bash

n=1

while [ $n -le 10 ]
do
  echo "$n"
  n=$(( n+1 ))
  sleep 2 #pause for 2 seconds
done
