//requireLib("mathUtils").

function AngleForIntersection {parameter Orbit1. parameter Orbit2. return Constant:RadToDeg * CONSTANT:PI * (1 - (1 / (2* SQRT(2))) * SQRT((Orbit1:SEMIMAJORAXIS/Orbit2:SEMIMAJORAXIS + 1)^3)).}

function TimeFromBurnToApproach {
	parameter Orbit1.
	parameter Orbit2.
	set sumPow to (Orbit1:SEMIMAJORAXIS+Orbit2:SEMIMAJORAXIS)^3.
	return CONSTANT:PI * SQRT(sumPow/(8*Orbit1:BODY:MU)).
}

function AOPVector {
	parameter TargetOrbit.

	set PosVec to TargetOrbit:POSITION - TargetOrbit:BODY:POSITION.
	set UpVector to VCRS(TargetOrbit:VELOCITY:ORBIT, PosVec):NORMALIZED.

	//set AOPVec to RotateVector(-TargetOrbit:TRUEANOMALY, UpVector, PosVec).

	print "Target True Anomaly: " + TargetOrbit:TRUEANOMALY.
	//return AOPVec.
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

	// print "Starting Orbit Adjustment - Target Orbit".

	// if InclinationAdjuster(TargetOrbit) > 0 {
	// 	print "Target Orbit unreachable, aborting procedure.".
	// 	abort.
	// }

	//set AOPVec to AOPVector(TargetOrbit).
	//set ObritalAngleToAOP to SHIP:OBT:TRUEANOMALY + vang(AOPVec, ship:position - BODY:position).
	//set orbitalAngleToA to mod(ObritalAngleToAOP + 180, 360).




	print "Inclination is set and we know the target angle".
	//print "Target True Anomaly: " + ObritalAngleToAOP.

	wait 100.
	print "Starting the Hohmann Manuver.".

	set IsRaising to (SHIP:ORBIT:SEMIMAJORAXIS - TargetOrbit:SEMIMAJORAXIS) < 0.

	Print "Final Orbit achieved.".
}
