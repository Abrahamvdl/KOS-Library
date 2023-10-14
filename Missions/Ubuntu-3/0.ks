PRINT "Counting down:".
FROM {local countdown is 2.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1.
}

lock steering to up.

lock throttle to 1.


PRINT "Launching now".	
STAGE.

// when stage:resourcesLex["SolidFuel"]:amount < 0.1 then{
//     PRINT "First Staging, dropping the boosters.".

//     set throttle to 0.15.
//     wait 0.7.
//     stage.

//     wait 1.5.
//     Print "Starting main engine.".
//     set throttle to 1.				
// }

wait 1.

until ship:status = "LANDED" {
    print ("Steering: " + steering) at (0, 10).
    print ("Heading:  " + heading) at (0, 11).
    wait 0.5.
}

wait until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED".
print "Ship landed.".
print "".
print "Shutting down.".
kuniverse:timewarp:cancelwarp().

// SET SHIP:CONTROL:PILOTMAINTHROTTLE to 0.

SHIP:partstagged("Launch")[0]:GETMODULEBYINDEX(0):DEACTIVATE.
SHUTDOWN.