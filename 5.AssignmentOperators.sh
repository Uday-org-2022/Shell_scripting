#!/bin/bash

read -p "Enter value of a : " a
read -p "Enter value of b : " b


#$(expr $a + $b)
# $((a+b))

add=$(expr $a + $b)
echo addition of a and b is $add

sub=$(expr $a - $b)
echo substraction of a and b is $sub

mult=$(expr $a \* $b)
echo multiplication of a and b is $mult

div=$(expr $a / $b)
echo Division of a and b is $div

modulus=$(expr $a % $b)
echo modulus of a and b is $modulus


echo increment is $((++a))
echo decrement is $((--b))
