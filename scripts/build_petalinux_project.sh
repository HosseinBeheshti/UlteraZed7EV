#!/bin/bash
shopt -s extglob
ORG_DIR=$(pwd) 
PROJ_NAME=ultrazed7ev
PROJ_DIR=$ORG_DIR/build/apu/$PROJ_NAME

echo "Started at" >> $ORG_DIR/build_petalinux_project_runtime.txt
date >> $ORG_DIR/build_petalinux_project_runtime.txt
cd $PROJ_DIR

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
# 5) run petalinux-config -> Image Packaging Configuration -> Root filesystem type -> (EXT4 (SD/eMMC/SATA/USB))
# 
# 6) Subsystem AUTO Hardware Settings -> Advanced bootable images storage Settings > u-boot env partition settings -> image storage media (primary sd)    
cp $ORG_DIR/petalinux/config $PROJ_DIR/project-spec/configs/config

# rootfs configuration: $ORG_DIR/petalinux/rootfs_config 
#
# 1) apps -> [*] gpio-demo
#
# 2) Image Features -> [*] auto-login
#
# 4) Petalinux Package Groups -> packagegroup-petalinux -> [*] packagegroup-petalinux
#
# 5) Petalinux Package Groups -> packagegroup-petalinux-display-debug -> [*] packagegroup-petalinux-display-debug 
#
# 6) Petalinux Package Groups -> packagegroup-petalinux-gstreamer -> [*] packagegroup-petalinux-gstreamer
#
# 7) Petalinux Package Groups -> packagegroup-petalinux-multimedia -> [*] packagegroup-petalinux-multimedia  
#
# 8) Petalinux Package Groups -> packagegroup-petalinux-openamp -> [*] packagegroup-petalinux-openamp
#
# 9) Petalinux Package Groups -> packagegroup-petalinux-python-modules -> [*] packagegroup-petalinux-python-modules
#
# 10) Petalinux Package Groups -> packagegroup-petalinux-qt -> [*] packagegroup-petalinux-qt
#
# 11) Petalinux Package Groups -> packagegroup-petalinux-v4lutils -> [*] packagegroup-petalinux-v4lutils
#
# 12) Petalinux Package Groups -> packagegroup-petalinux-v4lutils -> [*] packagegroup-petalinux-v4lutils
cp $ORG_DIR/petalinux/rootfs_config $PROJ_DIR/project-spec/configs/rootfs_config
petalinux-config -c rootfs --silentconfig 

# kernel configuration: $ORG_DIR/petalinux/config
#
# 1)

# Execute the Petalinux Build
petalinux-build
# Package the build into Boot Images
petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --u-boot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --force
echo "Finished at" >> $ORG_DIR/build_petalinux_project_runtime.txt
date >> $ORG_DIR/build_petalinux_project_runtime.txt
# prepare SD
# 
# tar xvf rootfs.tar.gz
# picocom terminal
## sudo picocom -b 115200 -r -l /dev/ttyUSB0