#!/bin/bash

function func1() {
    local name=$1
    echo The name is $name
}

name=uudhhay
echo name is $name:before
func1 uday
echo name is $name:after


