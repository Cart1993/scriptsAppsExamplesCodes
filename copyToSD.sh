#!/bin/bash

# Script to add the files into the SD Card to boot the ZCU208 board
# Developed by Christian Rangel @ gradiant
# Vigo, Spain 05/02/2026

# Check if the user has typed the needed argument
if [ -z "$1" ]; then
    echo "Use: sudo $0 <device_name>"
    echo "Example: sudo $0 sda"
    echo "--------------------------------------------"
    echo "USB devices connected at this moment:"
    lsblk -dno NAME,SIZE,TRAN | grep "usb"
    exit 1
fi

# Set up the device
DRIVE="/dev/$1"
BOOT_P="${DRIVE}1"
ROOTFS_P="${DRIVE}2"

# Create the temporary mounting points
echo "--- UPLOADING FIRMWARE AND KERNEL ---"
sudo mkdir -p /mnt/sd_boot /mnt/sd_rootfs

# Mount the patitions
sudo mount $BOOT_P /mnt/sd_boot
sudo mount $ROOTFS_P /mnt/sd_rootfs

# Copying the booting files
sudo cp images/linux/BOOT.BIN /mnt/sd_boot/
sudo cp images/linux/image.ub /mnt/sd_boot/
sudo cp images/linux/boot.scr /mnt/sd_boot/

# Uncompressed RootFS
echo "Extracting RootFS (be patience...)"
sudo tar -xf images/linux/rootfs.tar.gz -C /mnt/sd_rootfs/

# Finishing
echo "Synchronizing and unmounting..."
sync
sudo umount /mnt/sd_boot /mnt/sd_rootfs
sudo rm -rf /mnt/sd_boot /mnt/sd_rootfs

echo "------------------------------------------------"
echo "¡PROCESS COMPLETED! THE SD SHOULD BE READY"
echo "------------------------------------------------"
