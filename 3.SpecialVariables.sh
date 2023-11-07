#!/bin/bash

echo current Filenam script : $0
echo "First parameter : $1"
echo "Second parameter : $2"
echo quoted Values : $@

args=("$@")
echo arg1=${args[0]} arg2=${args[1]}

echo quoted values : $*
echo 'Total number of parameters : '$#
echo parameter gives the PID of the current shell : $$
echo last background running process PID : $!
echo "Last argument provide to previous command: $_"
echo "Exit status of last command that executed: $?"

