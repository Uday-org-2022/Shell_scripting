#!/bin/bash
#

read -p "Enter the Value of A :" A
read -p "Enter the value of B :" B

if [ $A -eq $B ]
then
echo $A and $B are equal
elif [ $A -gt $B ]
then
echo $A is greater than $B
else
echo $A is less than $B
fi
