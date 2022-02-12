#!/bin/bash
cd /root/archinstall
echo -ne "

          A
         AVA
        AVAVA
       AV/ \VA             [Welcome to archinstall!]
      AV/   \VA
     AV/     \VA
     V/       \V

"
chmod +x startup.sh && chmod +x user.sh && chmod +x drivers.sh && chmod +x desktop.sh
bash startup.sh
cd /root && mv archinstall /mnt/root
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
