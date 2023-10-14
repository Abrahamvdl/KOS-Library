requireLib("mathUtils").
toggle lights. //this is to turn on the reaction wheels

clearscreen.
clearscreen.
FROM {local x is 0.} UNTIL x = 11 STEP {set x to x+1.} DO {
  print " ".
}

function AngleForIntersection {
	parameter Orbit1, Orbit2.
	return abs(Constant:RadToDeg * CONSTANT:PI * (1 - 1.41421356237 * SQRT((Orbit1:SEMIMAJORAXIS/Orbit2:SEMIMAJORAXIS + 1)^3))).
}

function TimeFromBurnToApproach {
	parameter Orbit1,	Orbit2.
	set sumPow to (Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS)^3.
	return CONSTANT:PI * SQRT(sumPow/(8*Orbit1:BODY:MU)).
}

//delta V necessary for the orbits
function DELTAV1 {
	parameter Orbit1, Orbit2.
	set sum to Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS.
	return SQRT(Orbit1:BODY:MU/Orbit1:SEMIMAJORAXIS) * (SQRT(2*Orbit2:SEMIMAJORAXIS/sum) - 1).
}

function DELTAV2 {
	parameter Orbit1, Orbit2.
	set sum to Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS.
	return SQRT(Orbit2:BODY:MU/Orbit2:SEMIMAJORAXIS) * (1 - SQRT(2*Orbit1:SEMIMAJORAXIS/sum)).
}

function TOTALDELTAVFORHM {
	parameter Orbit1, Orbit2.

	return DELTAV1(Orbit1, Orbit2) + DELTAV2(Orbit1, Orbit2).
}

function ValueDiff {
	parameter Val1, Val2, tolerance.
	return val1 + tolerance > val2 and val1 - tolerance < val2.
}

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

	//we need some way to ensure that the angle we target is such that the target object is ahead us.
	lock ShipPointy to SHIP:POSITION - OBT:BODY:POSITION.
	lock TargetVector to TARGET:POSITION - OBT:BODY:POSITION.
  lock AngleDiff to vang(TargetVector, ShipPointy).
	set UpVector to vcrs(ShipPointy:NORMALIZED, SHIP:VELOCITY:ORBIT:NORMALIZED).
	lock TargetFlyToVector to RotateVector(AngleForIntersect, UpVector, ShipPointy).

//	set vd4 TO VECDRAW(Kerbin:position, TARGET:POSITION - Kerbin:position, RGB(1,0,0), "Target Pos", 1.0, TRUE, 0.2, TRUE,	TRUE ).

	toggle lights. wait 0.2.
  set kuniverse:timewarp:mode to "RAILS".
	until TargetFlyToVector:NORMALIZED * TargetVector:NORMALIZED >= 0.9996 {
		print "Angle Diff: " + AngleDiff at (0,0).
		print "Dot product of the two vectors of interest: " + TargetFlyToVector:NORMALIZED * TargetVector:NORMALIZED at (0,1).

		print " " at (0,2).
		print "Ship:LONG: " + SHIP:Longitude at (0,3).
		print "Mun:LONG: " + BODY("Mun"):Longitude at (0,4).

		CLEARVECDRAWS().

	  set vd1 TO VECDRAW(Kerbin:position, TargetVector, RGB(1,0,0), "Target", 1.0, TRUE, 0.2, TRUE,	TRUE ).
		set vd2 TO VECDRAW(Kerbin:position, ShipPointy, RGB(0,1,0), "Us", 1.0, TRUE, 0.2, TRUE,	TRUE ).
		set vd3 TO VECDRAW(Kerbin:position, TargetFlyToVector, RGB(0,0,1), "OurAim", 1.0, TRUE, 0.2, TRUE,	TRUE ).
		set vd4 TO VECDRAW(Kerbin:position, UpVector*ShipPointy:MAG, RGB(1,0,1), "UpVector", 1.0, TRUE, 0.2, TRUE,	TRUE ).

		set DiffVal to TargetFlyToVector:NORMALIZED * TargetVector:NORMALIZED.
		set kuniverse:timewarp:rate to -999/2*DiffVal + 1001/2. //y=mx+c
		wait 0.1.
	}
	kuniverse:timewarp:cancelwarp().
	CLEARVECDRAWS().
	wait until kuniverse:TimeWarp:ISSETTLED.
	wait 1.

  //Since we do not have access to Nodes, we will have to burn the exact amount of DeltaV calculated.
	toggle lights. wait 0.2.
  lock steering to PROGRADE.
	wait until (SHIP:FACING:FOREVECTOR:NORMALIZED * PROGRADE:FOREVECTOR:NORMALIZED) >= 0.9996.

  set initialDV to STAGE:DELTAV:CURRENT.
  set THROTTLE to 1.
  until (initialDV - STAGE:DELTAV:CURRENT) >= DV1 {
    print "DeltaV burned: " + (initialDV - STAGE:DELTAV:CURRENT) at (0,5).
  }
  set THROTTLE to 0.

	print "Mun Flyby burn completed.".
	wait 1.

	//with our current technology we can't know if we have a transition, so best is to wait and see.
	toggle lights. wait 0.2.
	set kuniverse:timewarp:mode to "RAILS".
	set kuniverse:timewarp:rate to 1000.
	wait until OBT:BODY:NAME = "Mun".
	kuniverse:timewarp:cancelwarp().
	wait until kuniverse:TimeWarp:ISSETTLED.
	wait 1.
}

if OBT:BODY:NAME = "Mun" {
  print "Enjoying Mum?".
  print "Lets do some science".

	print " ".

	local MysteryGoo is 0.
	local GeigerCounter is 0.
	local Thermometer is 0.

	set ShipParts to SHIP:PARTS.
	for Part in ShipParts{
	  // print "Part: " + Part:TITLE.
	  if Part:TITLE:Contains("Mystery Goo"){
	    set MysteryGoo to Part.
	  }
	  if Part:TITLE:Contains("Geiger Counter"){
	    set GeigerCounter to Part.
	  }
	  if Part:TITLE:Contains("Thermometer"){
	    set Thermometer to Part.
	  }
	}

	print "Start Geiger Counter".
	GeigerCounter:GETMODULE("Experiment"):DOEVENT("<b>radiation scan</b>: <color=#ffd200>stopped</color>").
	print "Start Mystery Goo".
	MysteryGoo:GETMODULE("Experiment"):DOEVENT("<b>mystery goo™ observation</b>: <color=#ffd200>stopped</color>").
	print "Start Thermometer".
	Thermometer:GETMODULE("Experiment"):DOEVENT("<b>temperature scan</b>: <color=#ffd200>stopped</color>").

	// set kuniverse:timewarp:mode to "RAILS".
	// set kuniverse:timewarp:rate to 100.

  //nothing to do until we are in the influence of Kerbin again.
  wait until OBT:BODY:NAME = "Kerbin".
	kuniverse:timewarp:cancelwarp().
  print "Leaving Mum.".
	wait 3.
}

if OBT:BODY:NAME = "Kerbin" {
  // after the flyby the PERIAPSIS is too col, so we want to raise it a bit higher.

	toggle lights. wait 0.2.

	//Adjust the PERIAPSIS to ensure a high capture of Kerbin.
	if PERIAPSIS > 50000 {
		lock STEERING to RETROGRADE.
		set throttle to 1.
		wait until PERIAPSIS < 60000.
		set throttle to 0.
	} else {
		lock STEERING to PROGRADE.
		set throttle to 1.
		wait until PERIAPSIS > 50000.
		set throttle to 0.
	}

  lock steering to RETROGRADE.

	toggle lights. wait 0.2.

	set wasAbove to false.

	when ALTITUDE < 70000 and wasAbove then{
		kuniverse:timewarp:cancelwarp().
		set kuniverse:timewarp:mode to "PHYSICS".
		set kuniverse:timewarp:rate to 4.
		set wasAbove to false.
		PRESERVE.
	}

	when ALTITUDE > 70000 and not wasAbove then{
		kuniverse:timewarp:cancelwarp().
		set kuniverse:timewarp:mode to "RAILS".
		set kuniverse:timewarp:rate to 100000.
		set wasAbove to true.
		PRESERVE.
	}

	when ALTITUDE < 70000 then {
		toggle lights. wait 1.2.
		set throttle to 1. //burn all the fuel.
		wait until STAGE:DELTAV:CURRENT < 2.
	}

	when PERIAPSIS < 50000 then{
		stage. //drop the fuel tank and engine.
	}

	until ALTITUDE < 50000{
		print "Current Alt: " + ALTITUDE at (0,5).
		print "Current PERIAPSIS: " + PERIAPSIS at (0,6).
	}

	toggle lights. wait 0.2.
  lock steering to SRFRETROGRADE.

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
