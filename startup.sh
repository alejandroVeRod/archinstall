#!/bin/bash
echo "[Starting] Archinstall Startup Script"
clear
##Keymap
echo -ne "[Running] Keymap

"
echo "Please select your desired keymap [de, us, uk...]:"
read layout
localectl list-keymaps | grep $layout
echo "Enter specific keyboard layout from the search results:"
read layout2
loadkeys $layout2
echo -ne "[Finished] Keymap

"

##WiFi
echo -ne "[Running] WiFi

"
#https://wiki.archlinux.org/title/Network_configuration/Wireless#Utilities
ip -c a
echo "Set-up WiFi Connection (Y/n)?"
read wifi
if [ $wifi == "y" ] || [ $wifi == "Y" ]; then
    echo "Enter the WiFi device name [wlan0, wlan1]:"
    read wdev
    echo "Enter the SSID / name of your WiFi network:"
    read ssid
    echo "Connecting, please enter your WiFi password:"
    iw dev $wdev connect $ssid
    echo "Attempting sync..."
    pacman -Sy
elif [ $wifi == "n" ] || [ $wifi == "N" ]; then
    echo "Skipping..."
fi
echo -ne "[Finished] WiFi

"

##Partitioning
echo -ne "[Running] Partitioning

"
#https://www.rodsbooks.com/gdisk/sgdisk-walkthrough.html
#https://linux.die.net/man/8/sgdisk
sgdisk -p /dev/sda && echo " "
sgdisk -p /dev/sdb && echo " "
sgdisk -p /dev/sdc && echo " "
sgdisk -p /dev/sdd && echo " "
echo -ne "Please choose the drive you want to use:
WARNING: The selected drive will be wiped entirely
"
read drive
sgdisk --zap-all /dev/$drive
echo -ne "Starting the partitioning process, see the example for a 1TB SSD:

> 'NEW', first sector hit ENTER for default
> Size enter 512MiB, ENTER; Specfiy efi boot partition, type: EF00
> Then enter name: 'boot'; Move down to the rest of the free space, ENTER

> First sector hit ENTER for default
> Size enter 16GiB, ENTER; Specfiy swap partition, type: 8200
> Then enter name: 'swap'; Move down to the rest of the free space, ENTER

> First sector hit ENTER for default
> Size enter 100GiB, ENTER; Specfiy linux fs partition, type: 8300
> Then enter name: 'root'; Move down to the rest of the free space, ENTER

> First sector hit ENTER for default
> Size press ENTER to use the rest of the drive; Specfiy linux fs partition, type: 8300
> Then enter name: 'home'; Move over to 'WRITE' and hit ENTER, type 'yes', then move to 'QUIT'
"
cgdisk /dev/$drive
mkfs.fat -F32 /dev/${drive}1
mkswap /dev/${drive}2
swapon /dev/${drive}2
mkfs.ext4 /dev/${drive}3
mkfs.ext4 /dev/${drive}4
mount /dev/${drive}3 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/${drive}1 /mnt/boot
mount /dev/${drive}4 /mnt/home
lsblk
echo -ne "[Finished] Partitioning

"

##Ranking Mirrors
echo -ne "[Running] Mirrors

"
clear
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
pacman -S pacman-contrib --noconfirm
rankmirrors -n 8 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
echo -ne "[Finished] Mirrors

"

##Basic OS Packages
echo -ne "[Running] Pacstrap

"
pacstrap -i /mnt base base-devel linux linux-firmware linux-headers --noconfirm
genfstab -U -p /mnt >> /mnt/etc/fstab
echo -ne "[Finished] Pacstrap

"

clear
echo -ne "[Exiting] Archinstall Startup Script

"
