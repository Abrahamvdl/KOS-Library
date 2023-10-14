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

  local p0 is inVal1.
  local p1 is inVal2.

  local q0 is Equation:CALL(p1,p0,eccentricity).
  local q1 is Equation:CALL(p1,p1,eccentricity).

	return {
    parameter MeanAnomoaly.
		set counter to 1.

    until counter >= maxN {
				set p to p1 - q1 * (p1 - p0)/(q1 - q0).

				if abs(p - p1) < tolerance {
					print "Found in: " + counter + " steps" at (0,29).
					return p.
				}
				set counter to counter + 1.
				set p0 to p1.
        set q0 to q1.
        set p1 to p.
        set q1 to Equation:CALL(MeanAnomoaly, p1, eccentricity).
		}

		//if we got here then the procedure actually failed, so we give a message and return p0
		print "Unable to find solution at MeanAnomoaly: " + q1.
		return p.
	}.
}

until true = false {
  clearscreen.

  print "Info Start".

  print "TARGET ORBIT:Position: " + myOrbit:Position.
  print "TARGET ORBIT:Velocity: " + myOrbit:VELOCITY.
  print "TARGET ORBIT APOAPSIS ETA: " + myOrbit:ETA:APOAPSIS.
  print "TARGET ORBIT Periapsis ETA: " + myOrbit:ETA:Periapsis.

  print "TARGET ORBIT PERIOD: " + myOrbit:PERIOD.

  set MeanAnomoalyC to (myOrbit:PERIOD - myOrbit:ETA:PERIAPSIS) / myOrbit:PERIOD * 360.

  set EccentricSolver to SecantSolver(MeanAnomoalyC + 20, MeanAnomoalyC, 50, 0.1, myOrbit:ECCENTRICITY, EccentricAnomaly ).

  set EccentricAnomalyVal to EccentricSolver:CALL(MeanAnomoalyC).

  set EccenParam to sqrt((1+myOrbit:ECCENTRICITY)/(1-myOrbit:ECCENTRICITY)).
  set TrueAnomalyFromEccentricAnon to 2 * arctan(EccenParam * tan(EccentricAnomalyVal/2)).

  // SET EccenVec to (myOrbit:VELOCITY:ORBIT:SQRMAGNITUDE/myOrbit:BODY:MU - 1/myOrbit:POSITION:MAG) * myOrbit:POSITION - (vdot(myOrbit:POSITION, myOrbit:VELOCITY:ORBIT)/myOrbit:BODY:MU) * myOrbit:VELOCITY:ORBIT.
  set OrbitActualPos to myOrbit:BODY:POSITION - myOrbit:POSITION.
  set hVec to vcrs(OrbitActualPos,myOrbit:VELOCITY:ORBIT).
  set EccenVec to vcrs(myOrbit:VELOCITY:ORBIT, hVec)/myOrbit:BODY:MU.

  // set EccenVecApproc to (myOrbit:POSITION:NORMALIZED - myOrbit:VELOCITY:ORBIT:NORMALIZED):NORMALIZED * myOrbit:SemiMajorAXIS.

  set TrueAnomalyCalc to arccos(vdot(EccenVec, OrbitActualPos)/(EccenVec:MAG * OrbitActualPos:MAG)).


  set e1 to myOrbit:ECCENTRICITY.
  set e2 to myOrbit:ECCENTRICITY*myOrbit:ECCENTRICITY.
  set e3 to myOrbit:ECCENTRICITY*myOrbit:ECCENTRICITY*myOrbit:ECCENTRICITY.
  set TrueAnomalyCalcFromMeanA to MeanAnomoalyC + (2*e1 - 0.25*e3)*sin(MeanAnomoalyC) + 1.25 * e2 * sin(2*MeanAnomoalyC) + 13/12 * e3 * sin(3*MeanAnomoalyC).

  print "Target Orbit ECCENTRICITY: " + myOrbit:ECCENTRICITY.
  print "Calc Mean Anomaly: " + MeanAnomoalyC.
  // print "Calc TrueAnomaly:  " + TrueAnomalyCalc.
  // print "Calc TrueAnomaly 1:" + TrueAnomalyCalcFromMeanA.
  print "ECCENTRIC Anomaly: " + EccentricAnomalyVal.
  print "TA From ECCENTRIC Anomaly :" + TrueAnomalyCalc.


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

  // set vd1 TO VECDRAW(Kerbin:position, AOPVec * myOrbit:PERIAPSIS , RGB(0,1,0), "Mean Anomaly Rot", 1.0, TRUE, 0.2, TRUE,	TRUE ).
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
