#!/bin/bash
shopt -s extglob
echo "Started at" >> ./create_petalinux_project_runtime.txt
date >> ./create_petalinux_project_runtime.txt
# directory settings
ORG_DIR=$(pwd) 
PROJ_NAME=ultrazed7ev
PROJ_DIR=$ORG_DIR/build/apu/$PROJ_NAME
mkdir -p ./build/apu/

if [ -d "$PROJ_DIR" ]; then
     printf "Removing previous files ...\n"
     rm -rf $PROJ_DIR;
fi
cp $ORG_DIR/build/pl/design_1_wrapper.xsa $ORG_DIR/build/apu/design_1_wrapper.xsa
cd $ORG_DIR/build/apu
# create project
petalinux-create --type project --template zynqMP --name $PROJ_NAME
# import hardware
cd $PROJ_DIR
# get hardware description
petalinux-config --get-hw-description=../ --silentconfig
echo "Finished at" >> ./create_petalinux_project_runtime.txt
date >> ./create_petalinux_project_runtime.txt