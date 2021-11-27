function mission_file {
  parameter file.
  return "0:/Missions/" + SHIPNAME + "/" + file.
}

function requireLib {
  parameter file.
  if not EXISTS("1:/" + file) copypath("0:/Library/" + file, "").
  runpath("1:/" + file).
}

function SetNextState{
  set S:OLDSTATE to S:STATE. 
  set S:STATE to (S:STATE[0]:TONUMBER + 1) + ".ksm".
  WRITEJSON(S,"S.json").
}

function main{
  // Bootup process
  set ship:control:pilotmainthrottle to 0.

  set S to READJSON("S.json").
  if EXISTS(S:STATE) {
    runpath(S:STATE).
  } else if HOMECONNECTION:ISCONNECTED {
    //first check if we have X.ks
    set xF to "X.ks".
    if EXISTS(mission_file(xF)) {
      copypath(mission_file(xF), "").
      movepath(mission_file(xF), mission_file(TIME:SECONDS + "_" + xF)).
      runpath(xF).
    } else { //else try to get S:STATE
      if EXIST(STATE:OLDSTATE) deletepath(STATE:OLDSTATE).
      copypath(mission_file(S:STATE), "").
      runpath(S:STATE).
    }
  } else {
    Print "Currently not Connected to HOME, can't get new STATE file".
    print "Waiting 5 Seconds then rebooting".
    wait 5.
    reboot.
  }
}

main().
