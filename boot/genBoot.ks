// Revised Boot Script v0.0.1
// Kevin Gisi
// http://youtube.com/gisikw

function build_command_filename {
  parameter n.
  return n + ".update.ks".
}

function core_has_tagname {
  return core:part:tag <> "".
}

function command_name {
  if not core_has_tagname() set core:tag to core:part:uid.
  return build_command_filename(core:tag).
}

function has_new_command {
  if not addons:rt:hasconnection(ship) return 0.
  return EXISTS("0:/activeMission/" + command_name()).  
}

function move_to_Completed {
	parameter filetoMove.
	
	set filename to TIME:SECONDS + "_" + filetoMove.
	print filename.
	
	movepath("0:/activeMission/" + filetoMove, "0:/activeMissionCompletedSteps/" + filename).
}

function run_new_command {
  //makes sure that there is only 1 update kept at a time.
  log "" to tmp.exec.ks. 
  deletepath("tmp.exec.ks").
  movepath(command_name(), "tmp.exec.ks").  
  runpath("tmp.exec.ks").
}

// Bootup process
set ship:control:pilotmainthrottle to 0.
if has_new_command() {
  copypath("0:/activeMission/"+ command_name(), "").
  move_to_Completed(command_name()).
  run_new_command().
 }
else if EXISTS("startup.ks") runpath("startup.ks").