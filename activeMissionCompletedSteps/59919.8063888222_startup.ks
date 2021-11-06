FUNCTION SteeringSelector {
	PARAMETER current_altitude.
	PARAMETER launchDirection.	
	
	if SHIP:VELOCITY:SURFACE:MAG > 100 {
		//Linear ALTITUDE adjustment
		set MyAngle to 90 * (1 - current_altitude/50000).
		print "My Steering Angle: " + MyAngle at (0,6).
	} else {
		set MyAngle to 90.
	}
  
	set MYSTEER to heading(launchDirection,MyAngle).
}

function OribitalVelocityTarget {
	PARAMETER CurrentAlt.
	
	//return 0.025 * CurrentAlt + 325.
	return 2350 * sin(90 * CurrentAlt / 160000).
}

clearscreen.

if SHIP:STATUS = "PRELAUNCH" {
	LOCK THROTTLE TO 1.0.  
	
	PRINT "Counting down:".
	FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
		PRINT "..." + countdown.
		WAIT 1. 
	}

	PRINT "Launching".
	STAGE.
	
	wait 2.
}

if SHIP:STATUS = "FLYING" {
	//first stage with boosters, we turn very little
	SET MYSTEER TO HEADING(90,90).
	LOCK STEERING TO MYSTEER. 
	UNTIL STAGE:DELTAV:CURRENT < 1 { 
		wait 0.5.
	
		print "My Apoapsis: " + SHIP:APOAPSIS at (0,5).

		SteeringSelector(SHIP:ALTITUDE,90).				
	}
	
	stage.
	wait 1.
	
	//second stage with main engine, we do a gravaty turn	
	lock steering to SRFPROGRADE.
	
	//let orbital velocity increase from current velocity to final orbital velocity on a linear bases
	//where the linear part is defined by the height again.
	
	//SET MYPID TO PIDLOOP(Kp, Ki, Kd, min_output, max_output, epsilon).
	set PID to PIDLOOP(0.9,0.005,0.05,0,1,0.001).
	set PID:SETPOINT to OribitalVelocityTarget(SHIP:ALTITUDE).
	
	set throtVal to 0.
	lock throttle to throtVal.
	
	until OBT:Velocity:ORBIT:MAG > 2300 {		
		set PID:SETPOINT to OribitalVelocityTarget(SHIP:ALTITUDE).
		set throtVal to PID:UPDATE(TIME:SECONDS, OBT:Velocity:ORBIT:MAG).
		
		print "Target Velocity: " + PID:SETPOINT at (0,7).
		print "Target Velocity: " + OribitalVelocityTarget(SHIP:ALTITUDE) at (0,8).
		wait 0.1.
	}
	
	Print "We got here, meaning we should be orbital".
	
}

if SHIP:STATUS = "SUBORBITAL" {
	//Do circularization

}

if SHIP:STATUS = "ORBITING" and OBT:BODY:NAME = "Kerbin" {
	//Do Mum approach.
}

if SHIP:STATUS = "ESCAPING" and OBT:BODY:NAME = "Kerbin" {
	//I suppose nothing to do here? 
}

if SHIP:STATUS = "ORBITING" and OBT:BODY:NAME = "Mum" {
	//TODO
}

if SHIP:STATUS = "ESCAPING" and OBT:BODY:NAME = "Mum" {
	//TODO
}

//TODO capturing and landing.











print "Orbit Achieved!!".
print "Good luck going to Mum.".

SHUTDOWN.