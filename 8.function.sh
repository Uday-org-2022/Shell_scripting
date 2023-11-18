#!/bin/bash
#

function hello() {
     echo Hello world
}

function print() {
   echo $1 $2 $3 $0
}
quit(){
   exit
}


hello
print Hello world 1#function_name arg1 arg2 arg3
print Hello world 2
quit
echo function used in this script
