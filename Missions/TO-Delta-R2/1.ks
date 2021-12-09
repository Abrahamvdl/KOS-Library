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
