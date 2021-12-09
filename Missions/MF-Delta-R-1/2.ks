if OBT:BODY:NAME = "Kerbin" {
  lock STEERING to RETROGRADE.
  set throttle to 1. //burn all the fuel.
  wait until PERIAPSIS < 50000.
  set throttle to 0.

  wait until ALTITUDE < 50000.
  set throttle to 1. //burn all the fuel.
  wait until STAGE:DELTAV:CURRENT < 2.
  stage. //drop the fuel tank and engine.

  lock steering to SRFRETROGRADE.
  wait until ALTITUDE < 10000.
  Stage.
	//unlock steering.

  print "waiting until we have landed.".

  wait until SHIP:STATUS = "LANDED".
  print "We have landed".
  SHUTDOWN.
}
