//Angle needed between two entities to reach the target orbit at the same position at the same time:
function AngleForIntersection {
	parameter Orbit1.
	parameter Orbit2.
	
	return PI * (1 - (1 / (2* SQRT(2))) * SQRT((Orbit1:SEMIMAJORAXIS/Orbit2:SEMIMAJORAXIS + 1)^3).
}

//Time from first burn to second burn: 
function TimeFromBurnToApproach {
	parameter Orbit1.
	parameter Orbit2.
	
	return PI * SQRT((Orbit1:SEMIMAJORAXIS/Orbit2:SEMIMAJORAXIS)^3/(8*Orbit1:BODY:MU).
}

//delta V necessary for the orbits
function DELTAV1 {
	parameter Orbit1.
	parameter Orbit2.
	
	return SQRT(2*Orbit1:BODY:MU/Orbit1:SEMIMAJORAXIS) * (SQRT(2*Orbit2:SEMIMAJORAXIS/(Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS)) - 1) 
}

function DELTAV2 {
	parameter Orbit1.
	parameter Orbit2.
	
	return SQRT(2*Orbit2:BODY:MU/Orbit2:SEMIMAJORAXIS) * (1 - SQRT(2*Orbit1:SEMIMAJORAXIS/(Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS))) 
}

function TOTALDELTAVFORHM {
	parameter Orbit1.
	parameter Orbit2.
	
	return DELTAV1(Orbit1, Orbit2) + DELTAV2(Orbit1, Orbit2).
}

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
		print "Adjusting Altitude: " + OurAltitude() at (0,0).		
			
		if ABS(OurAltitude() - TargetAltitude) < TargetAltitude * 0.1 {
			set throttleVal to 0.05.
		}
		
		wait 0.1.
	}
	
	lock THROTTLE to 0.
}	

function InclinationAdjuster {
	PARAMETER newOrbit.
	set ourOrbit to SHIP:ORBIT.			
	
	print "Starting Inclination Adjustment Section of the Orbital Allignment".
	
	lock inclinationTarget to newOrbit:Inclination - ourOrbit:Inclination.
	print "Initial Inclination Difference: " + inclinationTarget.
	
	if abs(inclinationTarget) > 1 {
		print "Inclination Adjustment Required".
	
		if inclinationTarget > 180 {
			lock inclinationTarget to 360 - newOrbit:Inclination - ourOrbit:Inclination.
		}
		if inclinationTarget < -180 {
			lock inclinationTarget to 360 + newOrbit:Inclination - ourOrbit:Inclination.
		}
		
		if inclinationTarget > 90 or inclinationTarget < -90 {
			print "ERROR: Target orbit is too inclined to reach".
			return 1.
		}
			
		print "Waiting until we are at the Longitude of Ascension/Desension.".
		
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
		}		
		kuniverse:timewarp:cancelwarp().
		
		print "Node reached".
		print "Orientating...".
		
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
			print "Current Inclination Difference: " + inclinationTarget at (0.0).
		}
		
		lock throttle to 0.
		print "Inclination target Achieved".
		return 0.	
	}else{
		Print "No Inclination Adjustment Required".
		return 0.
	}
	return 2.
}

Function HohmannManuver {	
	PARAMETER newOrbit.
	PARAMETER TargetAngle.
	PARAMETER CurrentAngle_func.
	
	set ourOrbit to SHIP:ORBIT.			

	Print "Starting Classic Hohmann Manuver".	
	
	set raiseOrbit to newOrbit:APOAPSIS - SHIP:ORBIT:APOAPSIS > 0.
	set targetPosition to newOrbit:POSITION:VEC.
	
	if raiseOrbit {	
		print "Raising Orbit Manuver".		
		set LongitudeCondition to { return CurrentAngle_func() - TargetAngle. }.
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
		set LongitudeCondition to { return mod(CurrentAngle_func() - TargetAngle + 180, 360). }.
		set SteeringDirection to { return RETROGRADE. }.
		set OurAltitude to { return SHIP:PERIAPSIS. }.
		
		PerformManuver(LongitudeCondition, SteeringDirection, OurAltitude, newOrbit:PERIAPSIS).		
		
		print "Circularization".
		set LongitudeCondition to { return SHIP:ORBIT:TRUEANOMALY. }.
		set SteeringDirection to { return SHIP:RETROGRADE. }.
		set OurAltitude to { return SHIP:PERIAPSIS. }.
		
		PerformManuver(LongitudeCondition, SteeringDirection, OurAltitude, newOrbit:APOAPSIS).
	}
	
	
}




//UNTESTED
function OrbitalAllignmentWithVessel {
	parameter TargetVessel.
	
	set ourOrbit to SHIP:ORBIT.		
	print "Starting Orbit Adjustment Procedure - Target Vessel".
	
	if InclinationAdjuster(TargetVessel:ORBIT) > 0 {
		"Target Orbit unreachable due to severe inclination, aborting procedure.".
		abort.
	}
	
	targetAngle = AngleForIntersection(ourOrbit, TargetVessel:ORBIT).
	set currentAngleDifference to { return VANG(SHIP:ORBIT:POSITION, TargetVessel:ORBIT:POSITION). }.
	
	HohmannManuver(TargetVessel:ORBIT, targetAngle, currentAngleDifference). 	
	
	
	
	Print "Final Orbit achieved.".
}

//UNDER CONSTRUCTION
function OrbitalAllignmentWithOrbit{
	parameter TargetOrbit.
	
	set ourOrbit to SHIP:ORBIT.		
	print "Starting Orbit Adjustment Procedure - Target Orbit".
	
	if InclinationAdjuster(TargetOrbit) > 0 {
		"Target Orbit unreachable due to severe inclination, aborting procedure.".
		abort.
	}
	
	targetAngle = AngleForIntersection(ourOrbit, TargetOrbit).
	
	set targetPosition to TargetOrbit:POSITION:VEC. //Assuming that the POSITION is at PERIAPSIS.
	set currentAngleDifference to { return VANG(SHIP:ORBIT:POSITION, targetPosition). }.
	
	HohmannManuver(TargetOrbit, targetAngle, currentAngleDifference). 	
	
	Print "Final Orbit achieved.".
}

//UNTESTED
function OrbitalAllignmentWithTransition{
	parameter TargetBody.
	
	set ourOrbit to SHIP:ORBIT.		
	print "Starting Orbit Adjustment Procedure - Target Body".
	
	if InclinationAdjuster(TargetBody:ORBIT) > 0 {
		"Target Orbit unreachable due to severe inclination, aborting procedure.".
		abort.
	}
	
	targetAngle = AngleForIntersection(ourOrbit, TargetBody:ORBIT).
	set currentAngleDifference to { return VANG(SHIP:ORBIT:POSITION, TargetBody:ORBIT:POSITION). }.
	
	HohmannManuver(TargetBody:ORBIT, targetAngle, currentAngleDifference). 	
	
	Print "Final Orbit achieved.".
}