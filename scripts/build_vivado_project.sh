#!/bin/bash
shopt -s extglob
echo "Started at" >> ./build_vivado_project_runtime.txt
date >> ./build_vivado_project_runtime.txt
# generate bitstream and export platform
vivado -mode tcl -source ./tcl/build_vivado_project.tcl -notrace
# check timing errors 
vivado -mode batch -source ./tcl/check_project_timing.tcl
if [ $? -eq 1 ]
then
    exit 1
fi
echo "Finished at" >> ./build_vivado_project_runtime.txt
date >> ./build_vivado_project_runtime.txt