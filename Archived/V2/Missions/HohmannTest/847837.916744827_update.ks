//Replace Boot Script

deletepath("HM2.ks").
deletepath("HM1.ks").
deletepath("startup.ks").

copypath("0:/boot/initBoot.ks", "1:/boot/initBoot.ks").
set CORE:BOOTFILENAME to "boot/initBoot.ks".
reboot.