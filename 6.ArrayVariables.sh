#!/bin/bash


platform=("AWS" "Azure" "GCP" "Openstack")

echo "${platform[@]}"
echo ${platform[*]}
echo "${!platform[@]}"
echo "${#platform[@]}"


echo ${platform[1]}

unset platform[1]
echo ${platform[1]}

