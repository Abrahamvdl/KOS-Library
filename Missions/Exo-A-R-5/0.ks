

print "Main Program Starting".



print "Starting the Launch computer".
SHIP:partstagged("Launch")[0]:GETMODULEBYINDEX(0):ACTIVATE.


// Abort triggers.
when (SHIP:DELTAV:CURRENT < 0.1 or SHIP:MAXTHRUST < 0.1) and SHIP:STATUS = "FLYING"  then {
    print "Out of fuel/No thrust Abort Triggered.".
    ABORT ON.
}

wait 8.

wait until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED".
print "Ship landed.".
print "".
print "Shutting down.".
kuniverse:timewarp:cancelwarp().

SET SHIP:CONTROL:PILOTMAINTHROTTLE to 0.

SHIP:partstagged("Launch")[0]:GETMODULEBYINDEX(0):DEACTIVATE.
SHUTDOWN.

