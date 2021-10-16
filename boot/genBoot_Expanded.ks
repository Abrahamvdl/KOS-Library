// Revised Boot Script v0.0.1
// Kevin Gisi
// http://youtube.com/gisikw

function mission_file_location {
  parameter file.  
  
  return "0:/Missions/" + core:tag + "/" + file.
}

function has_new_command {  
  if not addons:rt:hasconnection(ship) return 0.
  return EXISTS(mission_file_location("update.ks")).  
}

// Bootup process
set ship:control:pilotmainthrottle to 0.
if has_new_command() {
  copypath(mission_file_location("update.ks"), "").
  movepath(mission_file_location("update.ks"), mission_file_location(TIME:SECONDS + "_update.ks")).
  runpath("update.ks").
 }
else if EXISTS("startup.ks") runpath("startup.ks").