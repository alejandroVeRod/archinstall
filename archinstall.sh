#!/bin/bash
cd /root
echo -ne "

          A
         AVA
        AVAVA
       AV/ \VA             [Welcome to archinstall!]
      AV/   \VA
     AV/     \VA
     V/       \V

"

bash startup.sh
arch-chroot /mnt /root/archinstall/user.sh
arch-chroot /mnt /root/archinstall/drivers.sh
arch-chroot /mnt /root/archinstall/desktop.sh
echo "To finish up, type 'exit' to exit the chroot into the installation"
umount -l /mnt

echo -ne "

          A
         AVA
        AVAVA
       AV/ \VA             [The installation has been finished, type 'reboot now']
      AV/   \VA
     AV/     \VA
     V/       \V

"
