


wait until SHIP:STATUS = "LANDED" or SHIP:STATUS = "SPLASHED".
print "Ship landed.".
print "".
print "Shutting down.".
kuniverse:timewarp:cancelwarp().

SET SHIP.CONTROL.PILOTMAINTHROTTLE to 0.

SHUTDOWN.

