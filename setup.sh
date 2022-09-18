#!/usr/bin/env bash

# Drive Selection
read -p "Select Drive: " drivevar

# Disk Encryption Selection
read -srep "Enter Disk Encryption Password: " cryptvar
read -sp "Confirm Disk Encryption Password: " cryptvarconfirm
echo "*"
if [ "$cryptvar" == "$cryptvarconfirm" ]; then
    echo "Starting installation.."
else
    echo "Password do not Match! Aborting installation.."
    exit
fi

# Partitioning
sudo parted drivevar
mklabel gpt
p
