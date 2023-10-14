//Replace Boot Script

deletepath("HM.ks").
deletepath("startup.ks").

copypath("0:/boot/initBoot.ks", "1:/boot/initBoot.ks").
set CORE:BOOTFILENAME to "boot/initBoot.ks".
reboot.