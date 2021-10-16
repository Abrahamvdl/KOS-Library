Print "Starting Initial Boot".
wait 1.

set canStart to false.

print "Copying Startup file". 
if EXISTS("0:/activeMission/startup.ks") {
  copypath("0:/activeMission/startup.ks","").
  movepath("0:/activeMission/startup.ks", "0:/activeMissionCompletedSteps/" + TIME:SECONDS + "_startup.ks").
  set canStart to true.  
} else {
  print "Startup not yet available".
  print " ".
}

print "Copying Utilities".
if EXISTS("0:/library/utils.ks") {
	copypath("0:/library/utils.ks","1:/utils.ks").
	runpath("utils.ks").
}

print "Copying the main boot File".
if EXISTS("0:/boot/genBoot.ks") {
	copypath("0:/boot/genBoot","1:/boot/genBoot.ks").
	
	print "Main boot copied".
	
	if canStart {
		set CORE:BOOTFILENAME to "boot/genBoot.ks".
		deletepath("1:/boot/initBoot.ks").
	
		print "Starting Main boot in 2 seconds.".
		wait 2.
		REBOOT.
	}
} 
 
 set timerval to 10.
 until timerval <= 0 {
	Print("No startup found, waiting " + timerval+ "secs then retrying.").	
	wait 1.
	set timerval to timerval - 1.
 }
 
 REBOOT.