Print "Starting Initial Boot".
wait 1.

set canStart to false.

function build_command_filename {
  parameter mission.
  parameter file.
  return "0:/Missions/" + mission + "/" + file.
}

function core_has_tagname {
  return core:part:tag <> "".
}

function mission_file_location {
  parameter file.
  if not core_has_tagname() set core:tag to core:part:uid.
  return build_command_filename(core:tag, file).
}

print "Copying Startup file". 
set missionFile to mission_file_location("startup.ks").
if EXISTS(missionFile) {
  copypath(missionFile,"").
  movepath(missionFile, mission_file_location(TIME:SECONDS + "_startup.ks")).
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