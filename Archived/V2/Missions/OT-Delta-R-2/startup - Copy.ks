FUNCTION SteeringSelector {
	PARAMETER current_altitude.
	PARAMETER launchDirection.
	PARAMETER altitude_target.
	
	if SHIP:VELOCITY:SURFACE:MAG > 100 {
		//Linear ALTITUDE adjustment
		set MyAngle to 90 * (1 - current_altitude/70000).
		print "My Steering Angle: " + MyAngle at (0,6).
	} else {
		set MyAngle to 90.
	}
  
	set MYSTEER to heading(launchDirection,MyAngle).
}

LOCK THROTTLE TO 1.0.  

PRINT "Counting down:".
FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
}

PRINT "Launching".
STAGE.

//The new plan:
// Shortly after launch we turn toward where we want to go and then lock our steering to srfprograde
// then we want to use PID system to control the orbital speed 
// starting from about 300m/s to 2300m/s
// we will however have to check and make sure that circularization occurs and that the rocket 'chase' its appoapis to reach orbit. 

SET MYSTEER TO HEADING(90,90).
LOCK STEERING TO MYSTEER. 
UNTIL SHIP:APOAPSIS > 70000 { 
	wait 0.4.
	
	print "My Apoapsis: " + SHIP:APOAPSIS at (0,5).

	SteeringSelector(SHIP:ALTITUDE,90,100000).

	//Ship specific toggles to ensure it stay sane.
	if SHIP:VELOCITY:SURFACE:MAG > 300 { 
		LOCK THROTTLE to 0.66. 		
	}

	if STAGE:DELTAV:CURRENT < 1{
		stage.
		wait 1.		
	}
}

//if we get here then it means that atleast our APOAPSIS is above 100km meaning have suborbital flight.
LOCK THROTTLE to 0. //cut the engins, dont want to waste fuel while coasting up.

print "Apoapsis Target reached, waiting to get close to it to circularize".

//SET STEERING to HEADING(90,30). //horizontal allign
//LOCK THROTTLE to 0.1. //keep accerating into our direction.
set timeAhead to 47.

LOCK STEERING to HEADING(90,0). //horizontal allign
until ETA:APOAPSIS < timeAhead{
	print "Time to Apoapsis: " + ETA:APOAPSIS at (0,7).
}

set ThrottleLevel to 1.
LOCK THROTTLE to ThrottleLevel. //hard burn.

until abs(APOAPSIS - PERIAPSIS) < 100 or APOAPSIS > 80000 { //wait until circularized	
	print "Liquid fuel level: " + STAGE:DELTAV:CURRENT at (0,8).
	
	if ETA:APOAPSIS < timeAhead and PERIAPSIS < 0{
		set ThrottleLevel to max((timeAhead - ETA:APOAPSIS)/5, 1).
	} 
		
	if ETA:APOAPSIS > timeAhead and PERIAPSIS < 0{
		set ThrottleLevel to 0.
	}
	
	if PERIAPSIS > 0 {
		if ETA:APOAPSIS < 10 {
			set ThrottleLevel to (10 - ETA:APOAPSIS)/10.
		} else if ETA:APOAPSIS > ETA:PERIAPSIS {
			set ThrottleLevel to 1.//(OBT:PERIOD - ETA:APOAPSIS)/10.
		} else {
			set ThrottleLevel to 0.
		}
	}
	
	if STAGE:DELTAV:CURRENT < 1{
		stage.
		wait 1.		
	}
	wait 0.5.
}

lock THROTTLE to 0. 

print "Orbit Achieved!!".
print "Enjoying Space for a minute.".
set counter to 60.

lock steering to RETROGRADE.

until counter <= 0 { //wait a minute...
	print "Time remaining: " + counter at (0,9).
	wait 1.
	set counter to counter - 1.
}

print "Starting to De-orbit.".

wait 2.
lock throttle to 1. //deorbit.

when STAGE:DELTAV:CURRENT < 1 then {
	print "Dropping the last booster".
	stage.
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

SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0. 

SHUTDOWN.