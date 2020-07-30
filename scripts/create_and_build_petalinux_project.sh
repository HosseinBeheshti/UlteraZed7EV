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
# warning: current version need to change configuration manually 
# Add aarch64 sstate-cache
# 1) run petalinux-config
#         -> Yocto Settings
#            ->Local sstate feeds settings
#                ->local sstate feeds url
#                       (press Enter)
# 2) Provide the path of sstate-cache from above
#           Ex: /<path>/aarch64  for ZynqMP projects
# 
# Setting download mirror
# 3) run petalinux-config
#        -> Yocto Settings
#           -> Add pre-mirror url
# 	            ->  (press Enter)
#                   Clear default value
# 
# 4) Provide the path of sstate-cache from above
#       file://<path>/downloads for all projects
# 
# 5) run petalinux-config
#        -> Yocto Settings
#           -> Enable Network sstate feeds
#              [ ] excludes
# 
# 6) run petalinux-config
#        -> Yocto Settings
#           -> Enable BB NO NETWORK
#              [*] includes
# 
# 7) run petalinux-config
#        -> Image Packaging Configuration
#           -> Root filesystem type 
# 	            ->  (press Enter)
# 	                select INITRAMFS
# 
# Execute the Petalinux Build
petalinux-build
# Package the build into Boot Images
petalinux-package --boot --format BIN --fsbl images/linux/zynqmp_fsbl.elf --u-boot images/linux/u-boot.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --force
echo "Finished at" >> ./build_petalinux_project_runtime.txt
date >> ./build_petalinux_project_runtime.txt