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

SET MYSTEER TO HEADING(90,90).
LOCK STEERING TO MYSTEER. 
UNTIL SHIP:APOAPSIS > 70000 { 
	wait 0.4.

	set myHeight to SHIP:ALTITUDE.
	print "My Surface Height: " + myHeight at (0,5).

	SteeringSelector(myHeight,90,100000).

	//Ship specific toggles to ensure it stay sane.
	if SHIP:VELOCITY:SURFACE:MAG > 300 { LOCK THROTTLE to 0.66. }

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

LOCK STEERING to HEADING(90,0). //horizontal allign
wait until ETA:APOAPSIS < 45.  //  <--- this is ship sensitive
LOCK THROTTLE to 1. //hard burn.

until abs(APOAPSIS - PERIAPSIS) < 100 { //wait until circularized	
	print "Liquid fuel level: " + STAGE:DELTAV:CURRENT at (0,7).
	if STAGE:DELTAV:CURRENT < 1{
		stage.
		wait 1.		
	}
	wait 0.5.
}

lock THROTTLE to 0. 

print "Orbit Achieved!!".

wait 60. //wait a minute...


lock steering to RETROGRADE.
lock throttle to 1. //deorbit.

when SHIP:ALTITUDE < 50000 and SHIP:VELOCITY:SURFACE:MAG < 900 then {
	print "Deploying the Droge shutes".
	stage. 
}

when SHIP:ALTITUDE < 9000 and SHIP:VELOCITY:SURFACE:MAG < 290 then {
	print "Deploying the main parashutes".
	stage. 
}

wait until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED".
print "Ship landed.".
print "".
print "Shutting down.".

SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0. 

SHUTDOWN.