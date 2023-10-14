

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
	parameter init_curAngle, TargetAngle.

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

		print "p0: " + round(p0,3) at (0,  12). 
		print "s0: " + round(s0,3) at (14, 12). 
		print "v0: " + round(v0,3) at (28, 12).
		print "a0: " + round(a0,3) at (0,  13).
		print "jerk: " + round(jerk,3) at (14,13).

		until counter >= maxN {
				set distJerk to distanceJerk(s0, v0, a0, jerk, p0).
				set distJerkDer to distanceJerkDerivative (v0, a0, jerk, p0).
				set p to p0 - distJerk / distJerkDer.
				print "f(p0): " + round(distJerk, 3) at (0, 14).
				print "f'(p0): " + round(distJerkDer, 3) at (14, 14).


				if abs(p - p0) < tolerance {
					set previousTime to p.
					print "Found in: " + counter + " steps" at (0,15).
					return p.
				}
				set counter to counter + 1.
				set p0 to p.
		}

		//if we got here then the procedure actually failed, so we give a message and return p0
		print "Unable to find solution at time: " + round(previousTime, 3) at (0,16).
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

	local throttleController to PIDLOOP(1, 0.01, 0.01, 0.1, 1, 0).
	local mintAlt is minHeight.
	set throttleController:SETPOINT to targetAP.

	return {
		// if ALTITUDE < mintAlt{ // and ETA:APOAPSIS < targetAP {
		// 	print "A" at (20,20).
		// 	return 1.			
		// }

		// print "B" at (20,20).
		return throttleController:UPDATE(TIME:SECONDS, ETA:APOAPSIS).
	}.
}