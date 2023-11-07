#!/bin/bash

read -p "Enter the value of A : " A
read -p "ENter the value of B : " B

echo Enter only one option is : add,sub,mult,div
read choice

case $choice in
add) echo addition of $A and $B is - $(expr $A + $B) ;;
sub) echo subtraction of $A and $B is - $(expr $A - $B) ;;
mult) echo echo multiplication of $A and $B is - $(($A*$B)) ;;
div) echo Division of $A and $B is - $(($A/$B)) ;;
*) echo invalid choice: Please enter the valid choice
esac
