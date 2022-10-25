SHIP:PARTSDUBBED("CX-4181 Scriptable Control System")[0]:GETMODULEBYINDEX(0):DOEVENT("open terminal").
set terminal:WIDTH to 50.
set terminal:HEIGHT to 60.

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
    set boosterDropped to false.


    when STAGE:DELTAV:CURRENT < 0.02 and ALTITUDE > 11000 then{
		set throttle to 0.
		wait 0.7.
        PRINT "Droping the Booster".
		stage.
        wait 0.3.
        set boosterDropped to true.
    }

    WHEN    (ALTITUDE > 21000 and ALTITUDE < 29000) and 
            (SHIP:AIRSPEED > 40 and SHIP:AIRSPEED < 160) and 
            SHIP:STATUS = "FLYING" and 
            BODY:NAME = "Kerbin" then {
        PRINT "Mission Parameters achieved!!".        
        
        
        stage.
    }

    until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED"{

        print "Altitude:    " + ALTITUDE at (0,12).
        print "AirSpeed:    " + airspeed at (0,13).
        print "Ship Status: " + SHIP:STATUS at (0,14).
        print "BODY:        " + BODY:NAME at (0,15).


        wait 0.2.
    }


    wait until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED".
	print "Ship landed.".
	print "".
	print "Shutting down.".
	kuniverse:timewarp:cancelwarp().

	SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0.

	SHUTDOWN.

}