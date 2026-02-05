#!/bin/bash

# Script to remove and prepare the SD Card to boot the ZCU208 board
# We will prepare the SD Card to have two different partitions:
## 1._ Partition 0 - 1 GB FAT 16/32
## 2._ Partition 1 - 15GB ext4
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

# Checking if the device exists
if [ ! -b "$DRIVE" ]; then
    echo "ERROR: Device $DRIVE no appears or does not exist."
    exit 1
fi

# Checking if it is an USB device
TRANSPORT=$(lsblk -dno TRAN $DRIVE)
if [ "$TRANSPORT" != "usb" ]; then
    echo "SECURITY ERROR: The device $DRIVE is not an USB (it's $TRANSPORT)."
    echo "This script must allow to performs format to external devices."
    exit 1
fi

echo "--- PREPARATION OF THE SD CARD ---"
echo "Selected Device: $DRIVE"
lsblk -dno NAME,SIZE,MODEL $DRIVE
echo "--------------------------------------------"

# Double-Checking
read -p "Are you sure? We will remove all the data in $DRIVE. (Y/N): " confirm
if [[ $confirm != "Y" && $confirm != "y" ]]; then
    echo "Cancelled."
    exit 1
fi

# Unmount active partitions
echo "Desmontando $DRIVE..."
sudo umount ${DRIVE}* 2>/dev/null

# Automatic partitioning (1GB FAT32, EXT4)
echo "Partitioning..."
sudo sfdisk $DRIVE << EOF
label: dos
unit: sectors

${DRIVE}1 : start=2048, size=2097152, type=c, bootable
${DRIVE}2 : start=2099200, type=83
EOF

# Format & Labels
echo "Making partitions and format..."
sudo mkfs.vfat -F 32 -n BOOT ${DRIVE}1
sudo mkfs.ext4 -L rootfs ${DRIVE}2

echo "--------------------------------------------"
echo "¡SD IS SUCCESSFULLY PREPARED $DRIVE!"
lsblk -f $DRIVE
