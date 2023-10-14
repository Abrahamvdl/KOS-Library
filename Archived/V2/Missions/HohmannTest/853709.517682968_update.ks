//Replace Boot Script

copypath("0:/boot/initBoot.ks", "1:/boot/initBoot.ks").
set CORE:BOOTFILENAME to "boot/initBoot.ks".
reboot.