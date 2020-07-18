#!/bin/bash
shopt -s extglob

echo "Started at" >> ./create_vivado_project_runtime.txt
date >> ./create_vivado_project_runtime.txt
# prepare HLS IPs
# 
# prepare SysGen IPs
# 
# build vivado project
vivado -mode tcl -source ./tcl/creat_vivado_project.tcl -notrace
echo "Finished at" >> ./create_vivado_project_runtime.txt
date >> ./create_vivado_project_runtime.txt