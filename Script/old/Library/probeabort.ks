//Abort Probe

NOTIFY("Abort Program Initiated").

If PERIAPSIS > 60000 { //If we are in an orbit
	NOTIFY("Orbit detected. Trying Deorbitting.").
	
	LOCK STEERING to RETROGRADE.
	Wait 20.
	LOCK THROTTLE to 1.
	
	wait until PERIAPSIS < 35000 or SHIP.LIQUIDFUEL < 0.1 or SHIP.ELECTRICCHARGE < 5. 
	
	// I want something also to detect if we cant deorbit. 
	if PERIAPSIS > 70000{
		NOTIFY("WARNING!!!! CANNOT DEORBIT").
		
		//We dont do any thing further, but i suppose a shutdown is best to preserve power?
	}
}

if PERIAPSIS <= 60000{
	NOTIFY("Sub-orbital Sequence").
	
	LOCK THROTTLE to 0.
	Set SHIP:CONTROL:PILOTMAINTHROTTLE to 0. 
	
	wait 5. NOTIFY("Detaching").
	until false{ stage. }
}