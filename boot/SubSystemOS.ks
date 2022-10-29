function requireLib {
  parameter file.  
  runpath("1:/" + file).
}

function main{
  // Bootup process
  set ship:control:pilotmainthrottle to 0.

  set S to READJSON("S.json").
  if EXISTS(S:STATE) {
    runpath(S:STATE).
  }   
  shutdown.
}

main().
