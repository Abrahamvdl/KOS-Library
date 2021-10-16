function PerformManuver {
	PARAMETER FlyToLongitude.
	PARAMETER SteeringDirection.
	PARAMETER OurAltitude.
	PARAMETER TargetAltitude.		
	
	lock THROTTLE to 0.
		
	Print "Current Angle Difference: " + FlyToLongitude().			
	
	print ("Waiting until we arrive at the correct position in our orbit.").
	
	set kuniverse:timewarp:mode to "RAILS".
	until abs(FlyToLongitude() < 1 or FlyToLongitude() > 359 ){
		Print "Current Angle Difference: " + FlyToLongitude() at (0,1).		
		print TIME:SECONDS at (0,2).
		set rate to -((FlyToLongitude() - 180)^2)/32400 + 100.
		set kuniverse:timewarp:rate to rate.
		wait 0.1.
	}
	kuniverse:timewarp:cancelwarp().
	
	print ("Arrived at desired location").
	
	LOCK STEERING TO SteeringDirection():VECTOR.

	lock SteeringDifference to vang(steering, SHIP:FACING:FOREVECTOR).
	print "Initial Steering Difference: " + SteeringDifference.
		
	until SteeringDifference < 1{
		print "SteeringDifference: " + SteeringDifference at (0,0).
		wait 0.1.
	}
	
	Print "Performing the Burn manuver".

	set throttleVal to 1.0.
	lock THROTTLE to throttleVal.		

	until ABS(OurAltitude() - TargetAltitude) < TargetAltitude * 0.002  { 
		print "Current Steering Direction: " at (0,1).
		print SteeringDirection() at (0,2).
		
		print "Current Altitude: " at (0,4).
		print OurAltitude() at (0,5).
			
		if ABS(OurAltitude() - TargetAltitude) < TargetAltitude * 0.1 {
			set throttleVal to 0.05.
		}
		
		wait 0.1.
	}
	
	if STAGE:DELTAV:CURRENT < 1 {
		set CurrentThrottleLevel to THROTTLE.
		lock THROTTLE to 0.
		stage.
		wait 2.
		lock THROTTLE to CurrentThrottleLevel.			
	}
	wait 0.5.	
	
	lock THROTTLE to 0.
}	

Function HohmannManuver {	
	PARAMETER newOrbit.
	set ourOrbit to SHIP:ORBIT.		
	print "Starting Orbit Adjustment Procedure".
	
	lock inclinationTarget to newOrbit:Inclination - ourOrbit:Inclination.
	
	if abs(inclinationTarget) > 1 {
		print ("Inclination Adjustment Required").
	
		if inclinationTarget > 180 {
			lock inclinationTarget to 360 - newOrbit:Inclination - ourOrbit:Inclination.
		}
		if inclinationTarget < -180 {
			lock inclinationTarget to 360 + newOrbit:Inclination - ourOrbit:Inclination.
		}
		
		if inclinationTarget > 90 or inclinationTarget < -90 {
			print "ERROR: Target orbit is too inclined to reach".
			abort.
		}
		
		Print "Inclination difference: " + inclinationTarget.
			
		print ("Waiting until we are at the Longitude of Ascension/Desension.").
		
		lock targetLong to mod(SHIP:ORBIT:ARGUMENTOFPERIAPSIS + SHIP:ORBIT:TRUEANOMALY, 360). 
		set goingForDescension to 1.
			
		if targetLong < 180 { 
			lock targetLong to MOD(SHIP:ORBIT:ARGUMENTOFPERIAPSIS + SHIP:ORBIT:TRUEANOMALY + 180, 360).
			print "Going to Longitude of Desension".
			set goingForDescension to -1.
		}
		
		set kuniverse:timewarp:mode to "RAILS".
		until targetLong < 1 {
			print "Waiting until 0 :=: " + targetLong at (0,0).
			set kuniverse:timewarp:rate to (360 - targetLong) * 5.
			//wait 0.1.
		}		
		kuniverse:timewarp:cancelwarp().
		print ("Node reached").
		print ("Orientating...").
		
		LOCK STEERING TO goingForDescension * VCRS(SHIP:VELOCITY:ORBIT, BODY:POSITION).		

		lock SteeringDifference to vang(steering, SHIP:FACING:FOREVECTOR).
		print "Initial Steering Difference: " + SteeringDifference.
		
		until SteeringDifference < 0.31{
			print "SteeringDifference: " + SteeringDifference at (0,0).
			wait 0.1.
		}
		
		print ("Starting the burn.").
		set throttleSetting to 0.
		lock throttle to throttleSetting.
		
		until ABS(inclinationTarget) < 0.2 {
			set throttleSetting to min(ABS(inclinationTarget) / 2, 1). 
		}
		
		lock throttle to 0.
		print "Inclination target Achieved".
	
	}else{
		Print "No Inclination Adjustment Required".
	}

	Print "Starting Classic Hohmann Manuver".	
	
	set raiseOrbit to newOrbit:APOAPSIS - SHIP:ORBIT:APOAPSIS > 0.
	set targetPosition to newOrbit:POSITION:VEC.
	
	if raiseOrbit {	
		print "Raising Orbit Manuver".		
		set LongitudeCondition to { return VANG(SHIP:ORBIT:POSITION, targetPosition). }.
		set SteeringDirection to { return SHIP:PROGRADE. }.
		set OurAltitude to { return SHIP:APOAPSIS. }.
		
		PerformManuver(LongitudeCondition, SteeringDirection, OurAltitude, newOrbit:APOAPSIS).		
		
		print "Circularization".
		set LongitudeCondition to { return mod(SHIP:ORBIT:TRUEANOMALY + 180, 360). }.
		set SteeringDirection to { return SHIP:PROGRADE. }.
		set OurAltitude to { return SHIP:PERIAPSIS. }.
		
		PerformManuver(LongitudeCondition, SteeringDirection, OurAltitude, newOrbit:PERIAPSIS).		
	} else {
		print "Lowering Orbit Manuver".
		set LongitudeCondition to { return mod(VANG(SHIP:ORBIT:POSITION, targetPosition) + 180, 360). }.
		set SteeringDirection to { return PROGRADE. }.
		set OurAltitude to { return SHIP:PERIAPSIS. }.
		
		PerformManuver(LongitudeCondition, SteeringDirection, OurAltitude, newOrbit:PERIAPSIS).		
		
		print "Circularization".
		set LongitudeCondition to { return SHIP:ORBIT:TRUEANOMALY. }.
		set SteeringDirection to { return SHIP:PROGRADE. }.
		set OurAltitude to { return SHIP:PERIAPSIS. }.
		
		PerformManuver(LongitudeCondition, SteeringDirection, OurAltitude, newOrbit:APOAPSIS).
	}
	
	Print "Final Orbit achieved.".
}