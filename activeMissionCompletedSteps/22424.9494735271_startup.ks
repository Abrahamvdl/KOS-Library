
FUNCTION SteeringSelector {
	PARAMETER current_altitude.
	PARAMETER launchDirection.
	PARAMETER altitude_target.
	
	if SHIP:VELOCITY:SURFACE:MAG > 100 {
		//set MyAngle to -((myHeight-100)/75000)^2 + 90.
	
		//Linear ALTITUDE adjustment
		set MyAngle to 90 * (1 - current_altitude/70000).
		print "My Steering Angle: " + MyAngle at (0,6).
	} else {
		set MyAngle to 90.
	}
  
	set MYSTEER to heading(launchDirection,MyAngle).
}

//Next, we'll lock our throttle to 40%.
LOCK THROTTLE TO 1.0.  

//This is our countdown loop, which cycles from 2 to 0
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
}

//if we get here then it means that atleast our APOAPSIS is above 100km meaning have suborbital flight.
LOCK THROTTLE to 0. //cut the engins, dont want to waste fuel while coasting up.

print "Sub-orbital flight achieved.".

lock steering to RETROGRADE.
stage. //get rid of the vehicle.

when SHIP:ALTITUDE < 10000 and SHIP:VELOCITY:SURFACE:MAG < 500 then {
	stage. //deploy the parachutes.
}

wait 5. 

print "Shutting down.".

SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0. 

SHUTDOWN.