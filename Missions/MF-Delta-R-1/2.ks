if OBT:BODY:NAME = "Kerbin" {
  // after the flyby the PERIAPSIS is too col, so we want to raise it a bit higher.

  lock STEERING to PROGRADE.
  set throttle to 1. //burn all the fuel.
  wait until PERIAPSIS > 50000.
  set throttle to 0.

  lock throttle to RETROGRADE.

  set kuniverse:timewarp:mode to "RAILS".
  // until ETA:APOAPSIS < LengthOfBurn/2 {
  until ALTITUDE < 70000 {
    set kuniverse:timewarp:rate to 1000.
    wait 0.
  }
  kuniverse:timewarp:cancelwarp().

  set kuniverse:timewarp:mode to "PHYSICS".
  until ALTITUDE < 50000 {
    set kuniverse:timewarp:rate to 4.
    wait 0.
  }
  kuniverse:timewarp:cancelwarp().

  set throttle to 1. //burn all the fuel.
  wait until STAGE:DELTAV:CURRENT < 2.
  stage. //drop the fuel tank and engine.

  lock steering to SRFRETROGRADE.

  when ALTITUDE < 70000 then{
		set kuniverse:timewarp:mode to "PHYSICS".
		set kuniverse:timewarp:rate to 4.
	}

  when SHIP:ALTITUDE < 8000 and SHIP:VELOCITY:SURFACE:MAG < 140 then {
    print "Deploying the main parashutes".
    unlock steering.
    stage.
  }

  when SHIP:ALTITUDE < 9000 and SHIP:VELOCITY:SURFACE:MAG < 290 then {
    print "Deploying the Droge shutes".
    stage.
  }

  print "waiting until we have landed.".

  wait until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED".
  print "We have landed".
  print "Shutting down.".
	kuniverse:timewarp:cancelwarp().

  SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0.
  SHUTDOWN.
}
