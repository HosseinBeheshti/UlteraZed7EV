#!/bin/bash
shopt -s extglob
mkdir -p ./build/apu/
cd ./build/apu
echo "Started at" >> ./build_petalinux_project_runtime.txt
date >> ./build_petalinux_project_runtime.txt
# create project
petalinux-create --type project --template zynqMP --name uz7ev
# import hw
cp ../pl/design_1_wrapper.xsa ./design_1_wrapper.xsa
cd uz7ev
# configure project
petalinux-config --get-hw-description=../
# Execute the Petalinux Build
petalinux-build
# Package the build into Boot Images
petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --u-boot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --force
echo "Finished at" >> ./build_petalinux_project_runtime.txt
date >> ./build_petalinux_project_runtime.txt