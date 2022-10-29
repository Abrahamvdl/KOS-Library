

print "Main Program Starting".



print "Starting the Launch computer".
SHIP:partstagged("Launch")[0]:GETMODULEBYINDEX(0):activate.


print "Waiting a long time".
wait 500.

wait until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED".
print "Ship landed.".
print "".
print "Shutting down.".
kuniverse:timewarp:cancelwarp().

SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0.

SHUTDOWN.

