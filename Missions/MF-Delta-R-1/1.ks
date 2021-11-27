function AngleForIntersection {
	parameter Orbit1, Orbit2.
	return Constant:RadToDeg * CONSTANT:PI * (1 - (1 / (2* SQRT(2))) * SQRT((Orbit1:SEMIMAJORAXIS/Orbit2:SEMIMAJORAXIS + 1)^3)).
}

function TimeFromBurnToApproach {
	parameter Orbit1,	Orbit2.
	set sumPow to (Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS)^3.
	return CONSTANT:PI * SQRT(sumPow/(8*Orbit1:BODY:MU)).
}

//delta V necessary for the orbits
function DELTAV1 {
	parameter Orbit1, Orbit2.
	return SQRT(2*Orbit1:BODY:MU/Orbit1:SEMIMAJORAXIS) * (SQRT(2*Orbit2:SEMIMAJORAXIS/(Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS)) - 1).
}

function DELTAV2 {
	parameter Orbit1, Orbit2.
	return SQRT(2*Orbit2:BODY:MU/Orbit2:SEMIMAJORAXIS) * (1 - SQRT(2*Orbit1:SEMIMAJORAXIS/(Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS))).
}

function TOTALDELTAVFORHM {
	parameter Orbit1, Orbit2.

	return DELTAV1(Orbit1, Orbit2) + DELTAV2(Orbit1, Orbit2).
}

clearscreen.
Print "Now we are ready to go to Mun.".
print "And we have to do a half-Hohmann Transfer such that we create a flyby.".

if SHIP:STATUS = "ORBITING" and OBT:BODY:NAME = "Kerbin" {
	//Do Mum approach.
	print "Starting Mum approach.".

  set TARGET to "Mun".

  set AngleForIntersect to AngleForIntersection(OBT, TARGET:ORBIT).
  set DV1 to DELTAV1(OBT, TARGET:ORBIT).

  print "Target Angle is: " + AngleForIntersect.
  print "Target DeltaV1: " + DV1.

  lock AngleDiff to vang(SHIP:POSITION - Kerbin:POSITION, TARGET:POSITION - Kerbin:POSITION).

  set kuniverse:timewarp:mode to "RAILS".
	until ABS(AngleDiff - AngleForIntersect) < 1 {
		print "Angle Diff: " + ABS(AngleDiff - AngleForIntersect) at (0,10).

		set kuniverse:timewarp:rate to ABS(AngleDiff - AngleForIntersect) * 5.
		wait 0.1.
	}
	kuniverse:timewarp:cancelwarp().

  //Since we do not have access to Nodes, we will have to burn the exact amount of DeltaV calculated.
  lock steering to PROGRADE.

  set initialDV to STAGE:DELTAV:CURRENT.
  set THROTTLE to 1.
  until (initialDV - STAGE:DELTAV:CURRENT) >= DV1 {
    print "DeltaV burned: " + (initialDV - STAGE:DELTAV:CURRENT) at (0,11).
  }
  set THROTTLE to 0.

  if SHIP:STATUS = "ESCAPING" and OBT:BODY:NAME = "Kerbin" {
    print "We have a transition!".
    print "Waiting until we reach Mun.".

    wait until OBT:BODY:NAME = "Mun".
  }else{
    print "Transition not achieved.".
  }

  wait 10.
}

if SHIP:STATUS = "ESCAPING" and OBT:BODY:NAME = "Kerbin" {
	//I suppose nothing to do here?
}

if SHIP:STATUS = "ESCAPING" and OBT:BODY:NAME = "Mun" {
  print "Enjoying Mum?".
  print "Do some science".

  //nothing to do until we are in the influence of Kerbin again.
  wait until OBT:BODY:NAME = "Kerbin".
  print "Leaving Mum.".
}

if OBT:BODY:NAME = "Kerbin" {
  //TODO capturing and landing.
  wait until ETA:APOAPSIS < 20.
  print "Approaching the capture burn.".
  lock STEERING to RETROGRADE.
  set throttle to 1.
  wait until PERIAPSIS < 30000.
  set throttle to 0.

  print "Waiting until we reach the Kerbin atmosphere.".
  wait until ALTITUDE < 50000.
  set throttle to 1. //use up the rest of our fuel.

  stage. //drop the fuel tank and engine.

  lock steering to SRFRETROGRADE.
  wait until ALTITUDE < 10000.
  Stage.
}

SHUTDOWN.
