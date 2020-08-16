#!/bin/bash
shopt -s extglob
ORG_DIR=$(pwd) 
PROJ_NAME=ultrazed7ev
PROJ_DIR=$ORG_DIR/build/apu/$PROJ_NAME

echo "Started at" >> $ORG_DIR/build_petalinux_project_runtime.txt
date >> $ORG_DIR/build_petalinux_project_runtime.txt
cd $PROJ_DIR

# device tree : $ORG_DIR/petalinux/system-user.dtsi
cp $ORG_DIR/petalinux/system-user.dtsi $PROJ_DIR/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

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
# 6) run petalinux-config -> Image Packaging Configuration ->  (/dev/mmcblk1p2) Device node of SD device
# 
# 7) Subsystem AUTO Hardware Settings -> Advanced bootable images storage Settings -> u-boot env partition settings -> image storage media (primary sd)    
# 
# 8) Subsystem AUTO Hardware Settings -> SD/SDIO Settings -> Primary SD/SDIO (psu_sd_1) 
cp $ORG_DIR/petalinux/config $PROJ_DIR/project-spec/configs/config

# rootfs configuration: $ORG_DIR/petalinux/rootfs_config 
#
# 1) apps -> [*] gpio-demo
#
# 2) Image Features -> [*] auto-login
#
# 3) Petalinux Package Groups -> packagegroup-petalinux -> [*] packagegroup-petalinux
#
# 4) Petalinux Package Groups -> packagegroup-petalinux-multimedia -> [*] packagegroup-petalinux-multimedia  
#
# 5) Petalinux Package Groups -> packagegroup-petalinux-openamp -> [*] packagegroup-petalinux-openamp
#
# 6) Petalinux Package Groups -> packagegroup-petalinux-v4lutils -> [*] packagegroup-petalinux-v4lutils
#
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

# Configuring SD boot 
# Ref: UG1144 (v2020.1) PetaLinux Tools Documentation Reference Guide page: 76
# $ cp images/linux/BOOT.BIN /media/BOOT/ 
# $ cp images/linux/image.ub /media/BOOT/ 
# $ cp images/linux/boot.scr /media/BOOT/ 
# $ sudo tar xvf rootfs.tar.gz -C /media/rootfs
# picocom terminal
# sudo picocom -b 115200 -r -l /dev/ttyUSB0 