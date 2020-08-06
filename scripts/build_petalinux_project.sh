#!/bin/bash
shopt -s extglob
ORG_DIR=$(pwd) 
PROJ_NAME=ultrazed7ev
PROJ_DIR=$ORG_DIR/build/apu/$PROJ_NAM

echo "Started at" >> $ORG_DIR/build_petalinux_project_runtime.txt
date >> $ORG_DIR/build_petalinux_project_runtime.txt
# project configuration: $ORG_DIR/petalinux/config
#
# Add aarch64 sstate-cache and Setting download mirror
# 1) run petalinux-config -> Yocto Settings -> Local sstate feeds settings -> local sstate feeds url
#           Ex: /<path>/aarch64  for ZynqMP projects
#           (Ex: /tools/Xilinx/petalinux/sstate_aarch64_2020.1/aarch64)
# 
# 2) run petalinux-config -> Yocto Settings -> Add pre-mirror url
#       file://<path>/downloads for all projects
#       (Ex: file:///tools/Xilinx/petalinux/downloads)
# 
# 3) run petalinux-config -> Yocto Settings -> Enable Network sstate feeds -> [ ] excludes
# 
# 4) run petalinux-config -> Yocto Settings -> Enable BB NO NETWORK -> [*] includes
# 
# 5) run petalinux-config -> Image Packaging Configuration -> Root filesystem type -> (INITRAMFS)
# 

# kernel configuration: $ORG_DIR/petalinux/config

# Execute the Petalinux Build
cd ./build/apu/ultrazed7ev
petalinux-build
# Package the build into Boot Images
petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --u-boot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --force
echo "Finished at" >> $ORG_DIR/build_petalinux_project_runtime.txt
date >> $ORG_DIR/build_petalinux_project_runtime.txt
# picocom terminal
## sudo picocom -b 115200 -r -l /dev/ttyUSB0