//hellolaunch

//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.

//Next, we'll lock our throttle to 100%.
set throttleVal to 1.0.
LOCK THROTTLE TO throttleVal.   // 1.0 is the max, 0.0 is idle.

//This is our countdown loop, which cycles from 2 to 0
PRINT "Counting down:".
FROM {local countdown is 3.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. // pauses the script here for 1 second.
}

WHEN MAXTHRUST = 0 THEN {
    PRINT "Activate Stage".
    STAGE.
	if SHIP:ALTITUDE < 80000 {
		PRESERVE.
	}
	
    wait 0.5.
}.


SET MYSTEER TO HEADING(90,90).
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER
UNTIL SHIP:APOAPSIS > 100000 { //Remember, all altitudes will be in meters, not kilometers

  set myHeight to SHIP:ALTITUDE.
  print "My Surface Height: " + myHeight at (0,5).

  if SHIP:VELOCITY:SURFACE:MAG > 100 {
    //set MyAngle to -((myHeight-100)/75000)^2 + 90.
	set MyAngle to 90 * (1 - SHIP:ALTITUDE/100000).
    print "My Steering Angle: " + MyAngle at (0,6).
  } else {
    set MyAngle to 90.
  }
  
  if SHIP:VELOCITY:SURFACE:MAG > 300{
	set throttleVal to 0.667.
  }

  set MYSTEER to heading(90,MyAngle).
}.

print "APOAPSIS now at 100km".

