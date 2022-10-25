SHIP:PARTSDUBBED("CX-4181 Scriptable Control System")[0]:GETMODULEBYINDEX(0):DOEVENT("open terminal").
set terminal:WIDTH to 50.
set terminal:HEIGHT to 60.

requireLib("NewtonSolver.ksm").


clearscreen.

if SHIP:STATUS = "PRELAUNCH" {
	LOCK THROTTLE TO 0.15.

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
	when stage:resourcesLex["SolidFuel"]:amount < 0.1 then{
		PRINT "First Staging, dropping the boosters.".

		set throttle to 0.15.
		wait 0.7.
		stage.

		wait 1.5.
		Print "Starting main engine.".
		set throttle to 1.				
	}

	// when ALTITUDE > 300 then{
	// 	set kuniverse:timewarp:mode to "PHYSICS".
	// 	set kuniverse:timewarp:rate to 2.
	// }

	// when ALTITUDE > 50000 then{
	// 	set kuniverse:timewarp:mode to "PHYSICS".
	// 	set kuniverse:timewarp:rate to 4.
	// }

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
	Print "We are sub-orbital".
	Print "Dropping the main engine.".
	
	stage.

	Print "Enable the parachute.".

	lock steering to retrograde.
	
}



wait until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED".
print "Ship landed.".
print "".
print "Shutting down.".
kuniverse:timewarp:cancelwarp().

SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0.

SHUTDOWN.

