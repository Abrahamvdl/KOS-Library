function AngleForIntersection {parameter Orbit1. parameter Orbit2. return Constant:RadToDeg * CONSTANT:PI * (1 - (1 / (2* SQRT(2))) * SQRT((Orbit1:SEMIMAJORAXIS/Orbit2:SEMIMAJORAXIS + 1)^3)).}
function TimeFromBurnToApproach {
	parameter Orbit1. 
	parameter Orbit2. 
	set sumPow to (Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS)^3.
	return CONSTANT:PI * SQRT(sumPow/(8*Orbit1:BODY:MU)).
}

function PerformManuver {
	PARAMETER FlyToLongitude.
	PARAMETER SteeringDirection.
	PARAMETER OurAltitude.
	PARAMETER TargetAltitude.		
	
	lock THROTTLE to 0.
	
	print "Waiting for correct angle.".
	
	set kuniverse:timewarp:mode to "RAILS".
	until abs(FlyToLongitude() < 1 or FlyToLongitude() > 359 ){
		Print "Current Angle Diff: " + FlyToLongitude() at (0,1).		
		print TIME:SECONDS at (0,2).
		set rate to -((FlyToLongitude() - 180)^2)/32400 + 100.
		set kuniverse:timewarp:rate to rate.
		wait 0.1.
	}
	kuniverse:timewarp:cancelwarp().
	
	print "Arrived at location".
	
	LOCK STEERING TO SteeringDirection():VECTOR.

	lock SteeringDifference to vang(steering, SHIP:FACING:FOREVECTOR).	
		
	until SteeringDifference < 1{
		print "Steering Diff: " + SteeringDifference at (0,0).
		wait 0.1.
	}
	
	Print "Performing Burn".

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
	
	print "Starting Inclination Adjustment".
	
	lock inclinationTarget to newOrbit:Inclination - ourOrbit:Inclination.	
	
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
		
		lock targetLong to mod(SHIP:ORBIT:ARGUMENTOFPERIAPSIS + SHIP:ORBIT:TRUEANOMALY, 360). 
		set goingForDescension to 1.
			
		if targetLong < 180 { 
			lock targetLong to MOD(SHIP:ORBIT:ARGUMENTOFPERIAPSIS + SHIP:ORBIT:TRUEANOMALY + 180, 360).			
			set goingForDescension to -1.
		}
		
		set TargetPositionCondition to { return targetLong < 1. }.
		set TargetSteeringDirection to { return goingForDescension * VCRS(SHIP:VELOCITY:ORBIT, BODY:POSITION). }.
		set TargetBurnCondition to { return ABS(inclinationTarget) < 0.2. }.
		set TargetPositionIndicator to { return targetLong. }.
		set TargetBurnIndicator to { return inclinationTarget. }.
		set TimeWarpRate to { return (360 - targetLong) * 5. }.
		
		SingleManuver (	TargetPositionCondition, 
						TargetSteeringDirection, 
						TargetBurnCondition, 
						TargetPositionIndicator, 
						TargetBurnIndicator, 
						TimeWarpRate
					  ).
		
		return 0.	
	}else{
		Print "No Inc Adjustment Required".
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

function SingleManuver{
	parameter TargetPositionCondition. //Delegate that should return true when location is reached
	parameter TargetSteeringDirection. //Delegate for the steering
	parameter TargetBurnCondition. //Delegate that should return 0 when the altitude is reached (some function)
	
	parameter TargetPositionIndicator is {return "NONE".}.
	parameter TargetBurnIndicator is {return "NONE".}.
	parameter TimeWarpRate is {return 1.}.
	
	set kuniverse:timewarp:mode to "RAILS".
	until TargetPositionCondition() {
		if TargetPositionIndicator() <> "NONE" {
			print "Position Approach Diff: " + TargetPositionIndicator() at (0,0).
		}
		set kuniverse:timewarp:rate to TimeWarpRate().
		wait 0.1.
	}
	kuniverse:timewarp:cancelwarp().
	
	lock STEERING to TargetSteeringDirection().
	
	wait until vang(steering, SHIP:FACING:FOREVECTOR) < 0.2.
	
	print "Starting the burn.".
	set throttleSetting to 0.
	lock throttle to throttleSetting.
	
	set previousBurnVal to TargetBurnCondition().
	set failureCond to 0.	
	
	until TargetBurnCondition() < 0.1 {
		set throttleSetting to min(TargetBurnCondition()), 1). 
		if TargetBurnIndicator() <> "NONE" {
			print "Current Target Diff: " + TargetBurnIndicator() at (0,0).
		}
		
		wait 0.2.
		
		if previousBurnVal < TargetBurnCondition(){
			set failureCond to failureCond + 1.
		} else {
			set failureCond to 0.
		}
		
		set previousBurnVal to TargetBurnCondition().
		
		if failureCond > 1000 { //we are failing for 2 seconds now.
			print "MOVING AWAY FROM TARGET, ABORTING THE PROCEDURE!!!!".
			lock throttle to 0.
			abort.
		}
	}
	lock throttle to 0.
	
	print "Burn Condition Achieved.".
}

function OrbitalAllignmentWithOrbit{
	parameter TargetOrbit.
	
	set ourOrbit to SHIP:ORBIT.		
	print "Starting Orbit Adjustment - Target Orbit".
	
	if InclinationAdjuster(TargetOrbit) > 0 {
		"Target Orbit unreachable, aborting procedure.".
		abort.
	}
	
	//step 1: Determine if orbit raising or lowering
	set IsRaising to (ourOrbit:SEMIMAJORAXIS - TargetOrbit:SEMIMAJORAXIS) < 0.
			
	set TargetPositionCondition to {return false. }.
	set TargetSteeringDirection to {return false. }.
	set TargetBurnCondition to {return false. }.
	set TargetPositionIndicator to {return false. }.
	set TargetBurnIndicator to { return SHIP:OBT:Apoapsis - SHIP:OBT:PERIAPSIS. }.
	set TimeWarpRate to {return false. }.		
	
	if IsRaising { //Go to Periapsis and raise Apoapsis
		set TargetPositionCondition to { return ETA:PERIAPSIS < 5. }.
		set TargetSteeringDirection to { return PROGRADE. }.
		set TargetBurnCondition to { return ABS(SHIP:OBT:APOAPSIS - TargetOrbit:PERIAPSIS) / 1000 . }.
		set TargetPositionIndicator to { return ETA:APOAPSIS. }.			
		set TimeWarpRate to { return ETA:PERIAPSIS/ 20. }.
	} else { //Go to Apoapsis and lower Periapsis
		set TargetPositionCondition to { return ETA:APOAPSIS < 5. }.
		set TargetSteeringDirection to { return RETROGRADE. }.
		set TargetBurnCondition to { return ABS(SHIP:OBT:PERIAPSIS - TargetOrbit:APOAPSIS) / 1000 . }.
		set TargetPositionIndicator to { return ETA:PERIAPSIS. }.			
		set TimeWarpRate to { return ETA:APOAPSIS/ 20. }.
	}
	
	SingleManuver (	TargetPositionCondition, 
					TargetSteeringDirection, 
					TargetBurnCondition, 
					TargetPositionIndicator, 
					TargetBurnIndicator, 
					TimeWarpRate
				  ).
				  
	//We have reached the touch point of the 2 orbits, the plan now is to circularize here 
	//and then travel to the correct point and finalize the orbit there.
	
	if IsRaising { //Go to APOAPSIS and raise PERIAPSIS
		set TargetPositionCondition to { return ETA:APOAPSIS < 5. }.
		set TargetSteeringDirection to { return PROGRADE. }.
		set TargetBurnCondition to { return ABS(SHIP:OBT:APOAPSIS - SHIP:OBT:PERIAPSIS) / 1000 . }.
		set TargetPositionIndicator to { return ETA:APOAPSIS. }.			
		set TimeWarpRate to { return ETA:APOAPSIS/ 20. }.
	} else { //Go to PERIAPSIS and lower APOAPSIS
		set TargetPositionCondition to { return ETA:PERIAPSIS < 5. }.
		set TargetSteeringDirection to { return RETROGRADE. }.
		set TargetBurnCondition to { return ABS(SHIP:OBT:APOAPSIS - SHIP:OBT:PERIAPSIS) / 1000 . }.
		set TargetPositionIndicator to { return ETA:PERIAPSIS. }.			
		set TimeWarpRate to { return ETA:PERIAPSIS/ 20. }.
	}
	
	SingleManuver (	TargetPositionCondition, 
					TargetSteeringDirection, 
					TargetBurnCondition, 
					TargetPositionIndicator, 
					TargetBurnIndicator, 
					TimeWarpRate
				  ).
	} 
	
	//At this point we expect that the 2 orbits are touching we only need to 
	//raise/lower it at the correct point, which we need to find first.
	
	//But we have to test what we have up an until this point.....
	
	
	set targetAngle to AngleForIntersection(ourOrbit, TargetOrbit).
	
	set targetPosition to TargetOrbit:POSITION:VEC.
	set currentAngleDifference to { return VANG(SHIP:ORBIT:POSITION, targetPosition). }.
	
	HohmannManuver(TargetOrbit, targetAngle, currentAngleDifference). 	
	
	Print "Final Orbit achieved.".
}