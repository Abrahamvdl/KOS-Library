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













// Below is the startup script to test this, it shortcut some of the techniques to find the PERIAPSIS


function UF{parameter f. if addons:rt:hasconnection(ship){copypath("0:/library/"+f,"").}}
// UF("OA.ks").
UF("mathUtils").
// run OA.
run mathUtils.

//Orbit close to mum -- watch  out for transition
set ra to 10191593 + Kerbin:radius.
set rp to 10095538 + Kerbin:radius.
set inc to 0.
set longOfAscen to 0.
set arguOfPeri to 0.

set ra to 5040791 + Kerbin:radius.
set rp to 2539406 + Kerbin:radius.
set inc to 2.4.
set longOfAscen to 46.6.
set arguOfPeri to 71.9.

set ecen to (ra - rp) / (ra + rp).
set semiMajor to rp / (1 - ecen).

set TargetPos to V(0,0,0).
set PosSet to false.
set maxDistance to 0.
set minDistance to 0.
set HasMaxDist to false.

SET myOrbit TO CREATEORBIT(inc, ecen, semiMajor, longOfAscen, arguOfPeri, 0, 0, Kerbin).

//set target to "Gusson's Capsule".
//set myOrbit to target:OBT.

set EccentricAnomaly to {
  parameter M, EccenAnom, eccentricity.
  return EccenAnom - eccentricity * sin(EccenAnom) - M.
}.

function SecantSolver {
	parameter inVal1, inVal2, maxN, tolerance, eccentricity, Equation.

  local E0 is inVal1.
  local E1 is inVal2.

  local q0 is Equation:CALL(E0,E0,eccentricity).
  local q1 is Equation:CALL(E1,E1,eccentricity).

	return {
    parameter MeanAnomoaly.
		set counter to 1.

    set q1 to Equation:CALL(MeanAnomoaly, E1, eccentricity).

    print "E0: " + E0 at (0,24).
    print "E1: " + E1 at (0,25).
    print "q0: " + q0 at (0,26).
    print "q1: " + q1 at (0,27).
    print "Time: " + TIME:SECONDS at (0,28).

    until counter >= maxN {
				set p to E1 - q1 * ((E1 - E0)/(q1 - q0)).

				if abs(p - E1) < tolerance {
					print "Found in: " + counter + " steps" at (0,29).
					return p.
				}
				set counter to counter + 1.
				set E0 to E1.
        set q0 to q1.
        set E1 to p.
        set q1 to Equation:CALL(MeanAnomoaly, E1, eccentricity).
		}

		//if we got here then the procedure actually failed, so we give a message and return E0
		print "Unable to find solution at MeanAnomoaly: " + q1.
		return p.
	}.
}

set MeanAnomoalyC to (myOrbit:PERIOD - myOrbit:ETA:PERIAPSIS) / myOrbit:PERIOD * 360.
set EccentricSolver to SecantSolver(MeanAnomoalyC + 20, MeanAnomoalyC, 50, 0.1, myOrbit:ECCENTRICITY, EccentricAnomaly ).

until true = false {
  clearscreen.

  print "Info Start".

  print "TARGET ORBIT:Position: " + myOrbit:Position.
  print "TARGET ORBIT:Velocity: " + myOrbit:VELOCITY.
  print "TARGET ORBIT APOAPSIS ETA: " + myOrbit:ETA:APOAPSIS.
  print "TARGET ORBIT Periapsis ETA: " + myOrbit:ETA:Periapsis.

  print "TARGET ORBIT PERIOD: " + myOrbit:PERIOD.

	//https://en.wikipedia.org/wiki/Mean_anomaly
  //Mean Anomaly -- this value is very far off from the TrueAnomaly for inclined orbits.
  set MeanAnomoalyC to (myOrbit:PERIOD - myOrbit:ETA:PERIAPSIS) / myOrbit:PERIOD * 360.

	//https://en.wikipedia.org/wiki/Eccentric_anomaly -- botom of the page  ---- this technique work bests, but still have a large error
  set EccentricAnomalyVal to EccentricSolver:CALL(MeanAnomoalyC).

  set EccenParam to sqrt((1+myOrbit:ECCENTRICITY)/(1-myOrbit:ECCENTRICITY)).
  set TrueAnomalyFromEccentricAnon to 2 * arctan(EccenParam * tan(EccentricAnomalyVal/2)).

  //https://en.wikipedia.org/wiki/Eccentricity_vector  -- both equations below, but neither work, it may be that I made a mistake, but they follow the active vessel and not the target orbit.
  // SET EccenVec to (myOrbit:VELOCITY:ORBIT:SQRMAGNITUDE/myOrbit:BODY:MU - 1/myOrbit:POSITION:MAG) * myOrbit:POSITION - (vdot(myOrbit:POSITION, myOrbit:VELOCITY:ORBIT)/myOrbit:BODY:MU) * myOrbit:VELOCITY:ORBIT.
  set OrbitActualPos to myOrbit:BODY:POSITION - myOrbit:POSITION.
  set hVec to vcrs(OrbitActualPos,myOrbit:VELOCITY:ORBIT).
  set EccenVec to vcrs(myOrbit:VELOCITY:ORBIT, hVec)/myOrbit:BODY:MU.

  // set EccenVecApproc to (myOrbit:POSITION:NORMALIZED - myOrbit:VELOCITY:ORBIT:NORMALIZED):NORMALIZED * myOrbit:SemiMajorAXIS.

  set TrueAnomalyCalc to arccos(vdot(EccenVec, OrbitActualPos)/(EccenVec:MAG * OrbitActualPos:MAG)).


  //https://en.wikipedia.org/wiki/Equation_of_the_center  and https://en.wikipedia.org/wiki/Mean_anomaly  -- it seems to be a tiny bit better than the Mean Anomaly but really for eccentric orbits is very farrrrr off, but since it is a Taylor Series Expansion it will make sense that it will not work for eccentric orbits.
  set e1 to myOrbit:ECCENTRICITY.
  set e2 to myOrbit:ECCENTRICITY*myOrbit:ECCENTRICITY.
  set e3 to myOrbit:ECCENTRICITY*myOrbit:ECCENTRICITY*myOrbit:ECCENTRICITY.
  set TrueAnomalyCalcFromMeanA to MeanAnomoalyC + (2*e1 - 0.25*e3)*sin(MeanAnomoalyC) + 1.25 * e2 * sin(2*MeanAnomoalyC) + 13/12 * e3 * sin(3*MeanAnomoalyC).

  print "Target Orbit ECCENTRICITY: " + myOrbit:ECCENTRICITY.
  print "Calc Mean Anomaly: " + MeanAnomoalyC.
  // print "Calc TrueAnomaly:  " + TrueAnomalyCalc.
  // print "Calc TrueAnomaly 1:" + TrueAnomalyCalcFromMeanA.
  print "ECCENTRIC param: " + EccenParam.
  print "ECCENTRIC Anomaly: " + EccentricAnomalyVal.
  print "TA From ECCENTRIC Anomaly :" + TrueAnomalyFromEccentricAnon.


  set PosVec to (myOrbit:POSITION - myOrbit:BODY:POSITION):NORMALIZED.
  set UpVector to VCRS(PosVec, myOrbit:VELOCITY:ORBIT):NORMALIZED.

  set AOPVec to RotateVector(-MeanAnomoalyC, UpVector, PosVec).
  // set AOPVecX to RotateVector(-TrueAnomalyCalc, UpVector, PosVec).
  // set AOPVecX2 to RotateVector(-TrueAnomalyCalcFromMeanA, UpVector, PosVec).
  set AOPVecX3 to RotateVector(-TrueAnomalyFromEccentricAnon, UpVector, PosVec).


  // set AOPVec1 to RotateVector(10, UpVector, PosVec).
  // set AOPVec2 to RotateVector(20, UpVector, PosVec).
  // set AOPVec3 to RotateVector(30, UpVector, PosVec).

  CLEARVECDRAWS().

  set vd2 TO VECDRAW(Kerbin:position, myOrbit:POSITION - myOrbit:BODY:POSITION, RGB(1,0,0), "PosVector", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  set vd3 TO VECDRAW(Kerbin:position, UpVector * myOrbit:PERIAPSIS, RGB(0,0,1), "UpVector", 1.0, TRUE, 0.2, TRUE,	TRUE ).

   set vd1 TO VECDRAW(Kerbin:position, AOPVec * myOrbit:PERIAPSIS , RGB(0,1,0), "Mean Anomaly Rot", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  // set vdx TO VECDRAW(Kerbin:position, AOPVecX * myOrbit:PERIAPSIS , RGB(1,1,1), "True Anomoaly Rot", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  // set vdx2 TO VECDRAW(Kerbin:position, AOPVecX2 * myOrbit:PERIAPSIS , RGB(0.5,0.1,1), "True Anomoaly Calc2 Rot", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  set vdx3 TO VECDRAW(Kerbin:position, AOPVecX3 * myOrbit:PERIAPSIS , RGB(0.5,0.1,1), "True Anomoaly Calc2 Rot", 1.0, TRUE, 0.2, TRUE,	TRUE ).

  // set vda TO VECDRAW(Kerbin:position, AOPVec1 * myOrbit:PERIAPSIS , RGB(1,1,0), "RotatedVec A", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  // set vdb TO VECDRAW(Kerbin:position, AOPVec2 * myOrbit:PERIAPSIS , RGB(0,1,1), "RotatedVec B", 1.0, TRUE, 0.2, TRUE,	TRUE ).
  // set vdc TO VECDRAW(Kerbin:position, AOPVec3 * myOrbit:PERIAPSIS , RGB(1,0,1), "RotatedVec C", 1.0, TRUE, 0.2, TRUE,	TRUE ).

  wait 0.5.
}

//OrbitalAllignmentWithOrbit(myOrbit).

set orbitalAngle to vang(myOrbit:POSITION - Kerbin:position, ship:position - Kerbin:position).
print "Orbital Angle Diff: " + orbitalAngle.
