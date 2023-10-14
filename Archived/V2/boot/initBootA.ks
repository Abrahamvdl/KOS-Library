Print "Starting Initial Boot - Active Mission Version".
wait 1.

set canStart to false.

function mission_file_location {  
  return "0:/activeMission/startup.ks".
}

print "Copying Startup file". 
set missionFile to "0:/activeMission/startup.ks".
if EXISTS(missionFile) {
  copypath(missionFile,"").
  movepath(missionFile, "0:/activeMissionCompletedSteps/" + TIME:SECONDS + "_startup.ks").
  set canStart to true.  
} else {
  print "Startup not yet available".
  print " ".
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