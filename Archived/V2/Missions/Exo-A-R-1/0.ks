SHIP:PARTSDUBBED("CX-4181 Scriptable Control System")[0]:GETMODULEBYINDEX(0):DOEVENT("open terminal").
set terminal:WIDTH to 50.
set terminal:HEIGHT to 60.

requireLib("NewtonSolver.ksm").


clearscreen.

if SHIP:STATUS = "PRELAUNCH" {
	LOCK THROTTLE TO 1.0.

	PRINT "Counting down:".
	FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
		PRINT "..." + countdown.
		WAIT 1.
	}

	PRINT "Launching now".
	STAGE.

	wait 0.5.
}

if SHIP:STATUS = "FLYING" {
	when STAGE:DELTAV:CURRENT < 0.2 then{
		set throttle to 0.
		wait 0.7.
		stage.
		wait 0.3.
		set throttle to 1.
	}

	when ALTITUDE > 300 then{
		set kuniverse:timewarp:mode to "PHYSICS".
		set kuniverse:timewarp:rate to 2.
	}

	when ALTITUDE > 50000 then{
		set kuniverse:timewarp:mode to "PHYSICS".
		set kuniverse:timewarp:rate to 4.
	}

	set pitch_ang to 90.
	lock steering to heading(90,pitch_ang).

	set targetHeight to 50000.
	set initTime to InitialTIme(targetHeight).
	set maxN to 10. //should reach answer within 5 iterations.
	set tolerance to 1. //we want to be accurate to within 1 second.

	set newPitch to getNewPitchAngle(pitch_ang, initTime, 0).
	set solver to NewtonSolver(initTime, targetHeight, maxN, tolerance).
	// set throttleController to ThrottleControl(5000, 60).

	print "inititial Time: " + initTime.

	until altitude > targetHeight{
		//determine the pitch angle we should be at based on the current height and velocity.
		//acceleration and jerk will be derived.
		set timeToTarget to SolveForTime(solver).
		set pitch_ang to newPitch:call(timeToTarget).
		print "Time to target: " + timeToTarget at (0,20).
		print "Pitch Angle: " + pitch_ang at (0,21).

		// set throttle to throttleController:CALL().
		// print "ETA:APOAPSIS: " + ETA:APOAPSIS at (0,31).
		// print "Throtle Val: " + throttle at (0,32).

		wait 0.05.
	}

	set throttle to 0.
	Print "Launch section complete.".

	if OBT:APOAPSIS < 80000 {
		print "Minimum height no reached, unable to reach orbit.".
	}

	Print "Waiting until suborbital.".
	wait until SHIP:STATUS = "SUB_ORBITAL".
}

if SHIP:STATUS = "SUB_ORBITAL" {
	//Do circularization
	Print "Starting circularization".

	//we need to calculate how much deltaV is necessary to circuralize
	//then we need to calculate how long it will take to expend that deltaV,
	//then we can travel to correct ETA and then do the burn.

	when STAGE:DELTAV:CURRENT < 0.2 then{
		stage.
	}

	set eu to 1+OBT:ECCENTRICITY.
	set ed to 1-OBT:ECCENTRICITY.
	set vper to sqrt((eu*SHIP:BODY:MU)/(ed*OBT:SEMIMAJORAXIS)).
	set vap  to sqrt((ed*SHIP:BODY:MU)/(eu*OBT:SEMIMAJORAXIS)).

	set deltaVNeeded to vper - vap.

  set LengthOfBurn to deltaVNeeded / SHIP:MAXTHRUST.

	print "Expected Duration of Burn: " + LengthOfBurn.

	lock steering to prograde.

	set kuniverse:timewarp:mode to "RAILS".
	until ETA:APOAPSIS < LengthOfBurn/2 {
		set kuniverse:timewarp:rate to ETA:APOAPSIS - LengthOfBurn/2.
		wait 0.1.
	}
	kuniverse:timewarp:cancelwarp().

	wait until ETA:APOAPSIS < LengthOfBurn/2.
	set throttle to 1.

	set initialAP to OBT:APOAPSIS.
	set startTime to time:seconds.
	set isAtMinEllipse to false.
	set curEllipseVal to OBT:ECCENTRICITY.

	until abs(initialAP - OBT:PERIAPSIS) < 1000 or (isAtMinEllipse and OBT:ECCENTRICITY < 0.003)  {
		print "Current Difference: " + (OBT:APOAPSIS - OBT:PERIAPSIS) at (0,34).
		if OBT:ECCENTRICITY < curEllipseVal {
			set curEllipseVal to OBT:ECCENTRICITY.
			set isAtMinEllipse to false.
		}{
			set isAtMinEllipse to TRUE.
		}
	}

	set throttle to 0.
	set timeDiff to time:seconds - startTime.
	print "Burn time was: " + timeDiff.

	print "Orbit Achieved!!".
}

if SHIP:STATUS = "ORBITING" {
	print "Enjoying Space for a minute.".
	set counter to 10.

	lock steering to RETROGRADE.

	until counter <= 0 { //wait a minute...
		print "Time remaining: " + counter at (0,40).
		wait 1.
		set counter to counter - 1.
	}

	print "Starting to De-orbit.".

	lock throttle to 1. //deorbit.

	when STAGE:DELTAV:CURRENT < 1 then {
		print "Dropping the last engine".
		stage.
	}

	wait until STAGE:DELTAV:CURRENT < 1.
	set kuniverse:timewarp:mode to "RAILS".
	until ALTITUDE < 70000 {
		set kuniverse:timewarp:rate to 50.
		wait 0.1.
	}
	kuniverse:timewarp:cancelwarp().

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

	wait until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED".
	print "Ship landed.".
	print "".
	print "Shutting down.".
	kuniverse:timewarp:cancelwarp().

	SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0.

	SHUTDOWN.
}
