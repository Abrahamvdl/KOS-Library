function distanceAccel {
	parameter s0, v0, accel, t.
	return s0 + v0*t + 0.5*accel*t*t.
}

function distanceJerk {
	parameter s0, v0, a0, jerk, t.
	return s0 + v0*t + 0.5*a0*t*t + 0.1666666666667*jerk*t*t*t.
}

function distanceJerkDerivative {
	parameter v0, a0, jerk, t.
	return v0 + a0*t + 0.5*jerk*t*t.
}

function getNewPitchAngle {
	parameter init_curAngle, init_ttt, TargetAngle.

	local tlast is time:seconds.
	local currentAngle is init_curAngle.

	return {
		parameter ttt.

		local now is time:seconds.
		local dt  is now - tlast.
		if dt > 0 {
			set currentAngle to (TargetAngle - currentAngle) / ttt * dt + currentAngle.

			set tlast to now.
		}

		return currentAngle.
	}.
}



//What is nice about this function is that it keeps track of time and the previous value by it self, you just need to initialize it.
//Then in the future you just call it with a new input value, you can even call it without the input value later in the program, just to
//get the same output, since time did not advance.
function makeDerivator_N {
	parameter init_value, N_count is 0.
	//N_Count is a weigth, saying I am weighing the old value N_Count times more than the new value,
	//thus the higher the number the slower the value will change.
	local tlast is time:seconds.
	local der is 0.
	local der_last to 0.
	local inputLast is init_value.
	if init_value:isType("Vector"){
		set der to v(0,0,0).
	}

	return {
		parameter getInput.
		local now is time:seconds.
		local dt  is now - tlast.
		if dt > 0 {
			set der_next to (getInput - inputLast)/dt.
			set der to (N_count*der + der_next) / (N_count + 1).
			set inputLast to getInput.
			set tlast to now.
		}

		return der.
	}.
}

local v_accel_func to makeDerivator_N(0,10).
local v_jerk_func to makeDerivator_N(0,20).

function getVertAccel {
  return v_accel_func:call(verticalspeed).
}

function getVertJerk {
  return v_jerk_func:call(getVertAccel).
}

//we are going to use Newton's method to solve.
//pl = p_(n-1)
// p_n = pl - f(pl)/f'(pl)

function NewtonSolver {
	parameter initTime, targetHeight, maxN, tolerance.
	local previousTime is initTime.

	return {
		set p0 to previousTime.
		set counter to 1.
		set s0 to targetHeight - altitude.
		set v0 to -SHIP:VERTICALSPEED. //made negative because our reference from the top.
		set a0 to v_accel_func(v0).
		set jerk to v_jerk_func(a0).

		print "p0: " + p0 at (0,22).
		print "s0: " + s0 at (0,23).
		print "v0: " + v0 at (0,24).
		print "a0: " + a0 at (0,25).
		print "jerk: " + jerk at (0,26).

		until counter >= maxN {
				set p to p0 - distanceJerk(s0, v0, a0, jerk, p0) / distanceJerkDerivative (v0, a0, jerk, p0).
				print "f(p0): " + distanceJerk(s0, v0, a0, jerk, p0) at (0,27).
				print "f'(p0): " + distanceJerkDerivative(v0, a0, jerk, p0) at (0,28).


				if abs(p - p0) < tolerance {
					set previousTime to p.
					print "Found in: " + counter + " steps" at (0,29).
					return p.
				}
				set counter to counter + 1.
				set p0 to p.
		}

		//if we got here then the procedure actually failed, so we give a message and return p0
		print "Unable to find solution at time: " + previousTime.
		return previousTime.
	}.
}

function SolveForTime {
	parameter solver.
	return solver:call().
}

function InitialTIme {
	parameter targetHeight.
	return -SHIP:VERTICALSPEED + SQRT(SHIP:VERTICALSPEED * SHIP:VERTICALSPEED + 2*targetHeight*20).//this is just a very rough estimate
}

function ThrottleControl{
	parameter minHeight, targetAP.

	local throttleController to PIDLOOP(1,0.1,0.001,0.001,1,0).
	set throttleController:SETPOINT to targetAP.

	return {
		if ALTITUDE < minHeight and ETA:APOAPSIS < targetAP {
			return 1.
		}

		return throttleController:UPDATE(TIME:SECONDS, ETA:APOAPSIS).
	}.
}


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
stage.
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
		print "Time remaining: " + counter at (0,9).
		wait 1.
		set counter to counter - 1.
	}

	print "Starting to De-orbit.".

	lock throttle to 1. //deorbit.

	when STAGE:DELTAV:CURRENT < 1 then {
		print "Dropping the last booster".
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
