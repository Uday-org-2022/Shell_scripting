#!/bin/bash

read -p "ENter the Value of N : " n

if [ $n -gt 0 ]
then
   echo $n is a postive number
else 
   echo $n is a negative number
fi

