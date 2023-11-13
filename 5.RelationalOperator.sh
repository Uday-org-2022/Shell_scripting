#!/bin/bash
#
read -p "Enter a : " a
read -p "Enter b : " b

if (( $a==$b))
then
echo $a and $b are equal - True
else
echo $a and $b are not equal - False
fi

if (( $a!=$b ))
then
echo $a not equal to $b - True
else
echo $a is equal to $b - False
fi

if (( $a<$b ))
then
echo $a is less than  $b - True
else
echo $a is not less than  $b - False
fi

if (( $a<=$b ))
then
echo $a is less than or equal to  $b - True
else
echo $a is not less than or equal to  $b - False
fi

if (( $a>$b ))
then
echo $a is greater than  $b - True
else
echo $a is not greater than  $b - False
fi

if (( $a>=$b ))
then
echo $a is greater than or equal to  $b - True
else
echo $a is not greater than or equal to $b - False
fi




