//Zwei Tourist Rocket - just a launcher.

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

Function Notify{
	parameter message.
	
	HUDTEXT("kOS: " + message, 5, 2, 50, WHITE, false).
	print (message).
}

//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.

//Next, we'll lock our throttle to 40%.
LOCK THROTTLE TO 1.0.  

//This is our countdown loop, which cycles from 2 to 0
PRINT "Counting down:".
FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
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

//if we get here then it means that atleast our APOAPSIS is above 100km meaning we should now circularize.
LOCK THROTTLE to 0. //cut the engins, dont wnat to waste fuel while coasting up.

NOTIFY("Waiting until close to APOAPSIS").
SET STEERING to HEADING(90,30). //horizontal allign
LOCK THROTTLE to 0.1. //keep accerating into our direction.
wait until ETA:APOAPSIS < 45.  //  <--- this is ship sensitive

LOCK THROTTLE to 1. //hard burn.

LOCK STEERING to HEADING(90,0). //horizontal allign
wait 5. //make sure we have finished turning, for the big ship this seems to little.	
	

until PERIAPSIS > 80000{ //wait until circularized	
	print "Liquid fuel level: " + STAGE:DELTAV:CURRENT at (0,7).
	if STAGE:DELTAV:CURRENT < 1{
		stage.
		wait 1.		
	}
	wait 0.5.
}

lock THROTTLE to 0. 
NOTIFY ("ORBIT ACHIEVED").

wait 5. NOTIFY("Shutting down").
SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0. 
SHUTDOWN.