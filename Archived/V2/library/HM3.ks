function AngleForIntersection {parameter Orbit1. parameter Orbit2. return Constant:RadToDeg * CONSTANT:PI * (1 - (1 / (2* SQRT(2))) * SQRT((Orbit1:SEMIMAJORAXIS/Orbit2:SEMIMAJORAXIS + 1)^3)).}
function TimeFromBurnToApproach {
	parameter Orbit1. 
	parameter Orbit2. 
	set sumPow to (Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS)^3.
	return CONSTANT:PI * SQRT(sumPow/(8*Orbit1:BODY:MU)).
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
		set TargetBurnCondition to { return ABS(inclinationTarget). }.
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

function SingleManuver{
	parameter TargetPositionCondition, TargetSteeringDirection, TargetBurnCondition, TargetPositionIndicator, TargetBurnIndicator, TimeWarpRate.
	
	set kuniverse:timewarp:mode to "RAILS".
	until TargetPositionCondition() {		
		print "Position Approach Diff: " + TargetPositionIndicator() at (0,0).		
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
	
	until TargetBurnCondition() < 0.01 {
		set throttleSetting to min(TargetBurnCondition(), 1). 		
		print "Current Target Diff: " + TargetBurnIndicator() at (0,0).		
		
		wait 0.2.
		
		if previousBurnVal < TargetBurnCondition(){
			set failureCond to failureCond + 1.
		} else {
			set failureCond to 0.
		}
		
		set previousBurnVal to TargetBurnCondition().
		
		if failureCond > 1000 { 
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
	
	set orbitalAngleToP to 0.
	set orbitalAngleToA to 0.
	
	set assignP to {parameter inVal. set orbitalAngleToP to inVal.}.
	set assignA to {parameter inVal. set orbitalAngleToA to inVal.}.
	
	set hasFoundTarget to false.
	set timeToDestination to { return -1.}.
	
	if (TargetOrbit:ETA:PERIAPSIS < TargetOrbit:ETA:APOAPSIS) {
		set timeToDestination to {return TargetOrbit:ETA:PERIAPSIS.}.
		when TargetOrbit:ETA:PERIAPSIS < 1 then {
			assignP(mod(SHIP:OBT:TRUEANOMALY + vang(TargetOrbit:POSITION - BODY:position, ship:position - BODY:position),360)).			
			assignA(mod(orbitalAngleToP + 180, 360)).
			set hasFoundTarget to true.
		}
	} else {
		set timeToDestination to {return TargetOrbit:ETA:APOAPSIS.}.
		when TargetOrbit:ETA:APOAPSIS < 1 then {
			assignA(mod(SHIP:OBT:TRUEANOMALY + vang(TargetOrbit:POSITION - BODY:position, ship:position - BODY:position),360)).
			assignP(mod(orbitalAngleToA + 180, 360)).
			set hasFoundTarget to true.			
		}
	}
	
	print "Starting Orbit Adjustment - Target Orbit".
	
	if InclinationAdjuster(TargetOrbit) > 0 {
		print "Target Orbit unreachable, aborting procedure.".
		abort.
	}		
	
	set kuniverse:timewarp:mode to "RAILS".
	if not hasFoundTarget {
		print "Waiting until target Orbit PERIAPSIS/APOAPSIS angle is found".
		until timeToDestination() < 2 {
			print "Time remaining: " + timeToDestination() at (0,0).			
			set vd TO VECDRAW(Kerbin:position, TargetOrbit:POSITION - Kerbin:position, RGB(1,0,0), "Arrow 1", 1.0, TRUE, 0.2, TRUE,	TRUE ).				
			set kuniverse:timewarp:rate to timeToDestination()/2.			
			wait 0.1.
			CLEARVECDRAWS().
		}		
	}
	kuniverse:timewarp:cancelwarp().	
	
	print "Inclination is set and we know the target angle".
	print "Target True Anomaly: " + orbitalAngleToP.
	
	//wait 10.
	print "Starting the Hohmann Manuver.".
	
	set IsRaising to (SHIP:ORBIT:SEMIMAJORAXIS - TargetOrbit:SEMIMAJORAXIS) < 0.
			
	set TargetPositionCondition to {return false. }.
	set TargetSteeringDirection to {return false. }.
	set TargetBurnCondition to {return false. }.
	set TargetPositionIndicator to {return false. }.
	set TargetBurnIndicator to { return SHIP:OBT:Apoapsis - SHIP:OBT:PERIAPSIS. }.
	set TimeWarpRate to {return false. }.

	function angleDistance{parameter targetAngle, currentAngle.	if targetAngle > currentAngle {return targetAngle-currentAngle.}else{return 360-currentAngle+targetAngle.}	}
	
	if IsRaising {
		set TargetPositionCondition to { return angleDistance(orbitalAngleToP,ship:OBT:TRUEANOMALY) < 3. }.
		set TargetSteeringDirection to { return PROGRADE:FOREVECTOR. }.
		set TargetBurnCondition to { 
			set burnVal to 1 - (SHIP:OBT:APOAPSIS / (TargetOrbit:APOAPSIS * 1.01)).
			if burnVal > 0.1 return 1.
			else return burnVal.
		}.
		set TargetPositionIndicator to { return angleDistance(orbitalAngleToP,ship:OBT:TRUEANOMALY). }.			
		set TimeWarpRate to { 
			return angleDistance(orbitalAngleToA,ship:OBT:TRUEANOMALY)/2.			
		}.
	} else {
		set TargetPositionCondition to { return angleDistance(orbitalAngleToA,ship:OBT:TRUEANOMALY) < 3. }.
		set TargetSteeringDirection to { return RETROGRADE:FOREVECTOR. }.
		set TargetBurnCondition to { 
			set burnVal to 1 - (SHIP:OBT:PERIAPSIS / (TargetOrbit:PERIAPSIS * 0.99)). 
			if burnVal > 0.1 return 1.
			else return burnVal.
		}.
		set TargetPositionIndicator to { return angleDistance(orbitalAngleToA,ship:OBT:TRUEANOMALY). }.			
		set TimeWarpRate to { 
			return angleDistance(orbitalAngleToP,ship:OBT:TRUEANOMALY)/2.
		}.
	}
	
	SingleManuver (	TargetPositionCondition, 
					TargetSteeringDirection, 
					TargetBurnCondition, 
					TargetPositionIndicator, 
					TargetBurnIndicator, 
					TimeWarpRate
				  ).
	
	if IsRaising {
		set TargetPositionCondition to { return ETA:APOAPSIS < 30. }.
		set TargetSteeringDirection to { return PROGRADE:FOREVECTOR. }.
		set TargetBurnCondition to { 
		set burnVal to 1 - (SHIP:OBT:PERIAPSIS / TargetOrbit:PERIAPSIS). 
			if burnVal > 0.1 return 1.
			else return burnVal.
		}.
		set TargetPositionIndicator to { return ETA:APOAPSIS. }.			
		set TimeWarpRate to { return ETA:APOAPSIS/ 4. }.
	} else {
		set TargetPositionCondition to { return ETA:PERIAPSIS < 30. }.
		set TargetSteeringDirection to { return RETROGRADE:FOREVECTOR. }.
		set TargetBurnCondition to { 
			set burnVal to 1 -(SHIP:OBT:APOAPSIS / TargetOrbit:APOAPSIS). 
			if burnVal > 0.1 return 1.
			else return burnVal.
		}.
		set TargetPositionIndicator to { return ETA:PERIAPSIS. }.			
		set TimeWarpRate to { return ETA:PERIAPSIS/ 4. }.
	}
	
	SingleManuver (	TargetPositionCondition, 
					TargetSteeringDirection, 
					TargetBurnCondition, 
					TargetPositionIndicator, 
					TargetBurnIndicator, 
					TimeWarpRate
				  ).
	 	
	
	Print "Final Orbit achieved.".
}