set kuniverse:timewarp:mode to "RAILS".
until ETA:PERIAPSIS < 10 {
  set kuniverse:timewarp:rate to ETA:PERIAPSIS.
  wait 0.1.
}
kuniverse:timewarp:cancelwarp().

lock steering to PROGRADE.
set throttle to 1.

wait until APOAPSIS > 415000.
set throttle to 0.

set kuniverse:timewarp:mode to "RAILS".
until ETA:APOAPSIS < 10 {
  set kuniverse:timewarp:rate to ETA:APOAPSIS.
  wait 0.1.
}
kuniverse:timewarp:cancelwarp().

//at this point we should have satisfied the contract paramters so we lower the PERIAPSIS and stage.

lock STEERING to RETROGRADE.
set throttle to 1.
wait until PERIAPSIS < 50000.
set throttle to 0.

stage.  

lock steering to SRFRETROGRADE.
wait until ALTITUDE < 10000.
Stage.

when ALTITUDE < 1000 then unlock steering.

print "waiting until we have landed.".

wait until SHIP:STATUS = "LANDED".
print "We have landed".
SHUTDOWN.
